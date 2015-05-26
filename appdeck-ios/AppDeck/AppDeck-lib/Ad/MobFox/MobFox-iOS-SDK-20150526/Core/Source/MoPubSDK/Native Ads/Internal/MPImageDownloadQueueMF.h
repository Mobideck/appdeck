//
//  MPImageDownloadQueue.h
// 
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MPImageDownloadQueueCompletionBlockMF)(NSArray *errors);

@interface MPImageDownloadQueueMF : NSObject

// pass useCachedImage:NO to force download of images. default is YES, cached images will not be re-downloaded
- (void)addDownloadImageURLs:(NSArray *)imageURLs completionBlock:(MPImageDownloadQueueCompletionBlockMF)completionBlock;
- (void)addDownloadImageURLs:(NSArray *)imageURLs completionBlock:(MPImageDownloadQueueCompletionBlockMF)completionBlock useCachedImage:(BOOL)useCachedImage;

- (void)cancelAllDownloads;

@end
