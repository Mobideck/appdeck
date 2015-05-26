//
//  MPImageDownloadQueue.m
//  
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPImageDownloadQueueMF.h"
#import "MPNativeAdErrorMF.h"
#import "MpLoggingMF.h"
#import "MPNativeCacheMF.h"

@interface MPImageDownloadQueueMF ()

@property (atomic, retain) NSOperationQueue *imageDownloadQueue;
@property (atomic, assign) BOOL isCanceled;

@end

@implementation MPImageDownloadQueueMF

- (id)init
{
    self = [super init];
    
    if (self != nil) {
        _imageDownloadQueue = [[NSOperationQueue alloc] init];
        [_imageDownloadQueue setMaxConcurrentOperationCount:1]; // serial queue
    }
    
    return self;
}

- (void)dealloc
{
    [_imageDownloadQueue cancelAllOperations];
    [_imageDownloadQueue release];
    
    [super dealloc];
}

- (void)addDownloadImageURLs:(NSArray *)imageURLs completionBlock:(MPImageDownloadQueueCompletionBlockMF)completionBlock
{
    [self addDownloadImageURLs:imageURLs completionBlock:completionBlock useCachedImage:YES];
}

- (void)addDownloadImageURLs:(NSArray *)imageURLs completionBlock:(MPImageDownloadQueueCompletionBlockMF)completionBlock useCachedImage:(BOOL)useCachedImage
{
    __block NSMutableArray *errors = nil;
    
    for (NSURL *imageURL in imageURLs) {
        [self.imageDownloadQueue addOperationWithBlock:^{
            @autoreleasepool {
                if (![[MPNativeCacheMF sharedCache] cachedDataExistsForKey:imageURL.absoluteString] || !useCachedImage) {
                    MPLogDebugMF(@"Downloading %@", imageURL);
                    
                    NSURLResponse *response = nil;
                    NSError *error = nil;
                    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:imageURL]
                                                         returningResponse:&response
                                                                     error:&error];
                    if (data != nil) {
                        [[MPNativeCacheMF sharedCache] storeData:data forKey:imageURL.absoluteString];
                    } else {
                        if (error == nil) {
                            error = [NSError errorWithDomain:MoPubNativeAdsSDKDomainMF code:MPNativeAdErrorImageDownloadFailed userInfo:nil];
                        }
                        
                        if (errors == nil) {
                            errors = [[NSMutableArray array] retain];
                        }
                        
                        [errors addObject:error];
                    }
                }
            }
        }];
    }
    
    // after all images have been downloaded, invoke callback on main thread
    [self.imageDownloadQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.isCanceled) {
                completionBlock([errors autorelease]);
            }
            else {
                [errors release];
            }
        });
    }];
}

- (void)cancelAllDownloads
{
    self.isCanceled = YES;
    [self.imageDownloadQueue cancelAllOperations];
}

@end
