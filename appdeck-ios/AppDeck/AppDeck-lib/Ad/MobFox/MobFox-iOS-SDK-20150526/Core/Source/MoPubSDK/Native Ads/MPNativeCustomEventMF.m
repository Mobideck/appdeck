//
//  MPNativeCustomEvent.m
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeCustomEventMF.h"
#import "MPNativeAdErrorMF.h"
#import "MPImageDownloadQueueMF.h"
#import "MpLoggingMF.h"

@interface MPNativeCustomEventMF ()

@property (nonatomic, retain) MPImageDownloadQueueMF *imageDownloadQueue;

@end

@implementation MPNativeCustomEventMF

- (id)init
{
    self = [super init];
    if (self) {
        _imageDownloadQueue = [[MPImageDownloadQueueMF alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [_imageDownloadQueue release];

    [super dealloc];
}

- (void)precacheImagesWithURLs:(NSArray *)imageURLs completionBlock:(void (^)(NSArray *errors))completionBlock
{
    if (imageURLs.count > 0) {
        [_imageDownloadQueue addDownloadImageURLs:imageURLs completionBlock:^(NSArray *errors) {
            if (completionBlock) {
                completionBlock(errors);
            }
        }];
    }
    else {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    /*override with custom network behavior*/
}

@end
