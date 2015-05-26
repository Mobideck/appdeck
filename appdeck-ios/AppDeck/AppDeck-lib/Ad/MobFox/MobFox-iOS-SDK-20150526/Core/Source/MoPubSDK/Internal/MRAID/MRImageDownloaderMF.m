//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MRImageDownloaderMF.h"
#import "MPCoreInstanceProviderMF.h"

@interface MRAIDStorePictureOperationMF : NSOperation

@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) NSData *imageData;

- (id)initWithURL:(NSURL *)URL;

@end

@implementation MRAIDStorePictureOperationMF

@synthesize URL = _URL;
@synthesize imageData = _imageData;

- (id)initWithURL:(NSURL *)URL
{
    if (self = [super init]) {
        self.URL = URL;
    }
    return self;
}

- (void)dealloc
{
    [_URL release];
    [_imageData release];
    [super dealloc];
}

- (void)main
{
    self.imageData = [NSData dataWithContentsOfURL:self.URL];
}

@end

@implementation MRImageDownloaderMF

@synthesize queue = _queue;
@synthesize delegate = _delegate;
@synthesize pendingOperations = _pendingOperations;

- (id)initWithDelegate:(id<MRImageDownloaderDelegateMF>)delegate
{
    self = [super init];

    if (self) {
        self.delegate = delegate;
        self.pendingOperations = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)dealloc
{
    [_queue release];
    [_pendingOperations release];
    [super dealloc];
}

- (void)downloadImageWithURL:(NSURL *)URL
{
    if (!self.queue) {
        self.queue = [[MPCoreInstanceProviderMF sharedProvider] sharedOperationQueue];
    }

    if ([self.pendingOperations objectForKey:URL]) {
        // Already trying to download this image, so no need to kick off another download.
        return;
    }

    MRAIDStorePictureOperationMF *operation = [[[MRAIDStorePictureOperationMF alloc] initWithURL:URL] autorelease];
    [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:nil];
    [self.pendingOperations setObject:operation forKey:URL];
    [self.queue addOperation:operation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isFinished"] &&
            [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue] == NSKeyValueChangeSetting &&
            [[change objectForKey:NSKeyValueChangeNewKey] boolValue] == YES) {
        MRAIDStorePictureOperationMF *operation = object;
        [self performSelectorOnMainThread:@selector(saveImageForOperation:)
                               withObject:operation
                            waitUntilDone:NO];
    }
}

- (void)saveImageForOperation:(MRAIDStorePictureOperationMF *)operation
{
    UIImage *image = [UIImage imageWithData:operation.imageData];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), operation);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    MRAIDStorePictureOperationMF *operation = contextInfo;

    if (error) {
        [self.delegate downloaderDidFailToSaveImageWithURL:operation.URL error:error];
    }

    [operation removeObserver:self forKeyPath:@"isFinished"];
    [self.pendingOperations removeObjectForKey:operation.URL];
}

@end
