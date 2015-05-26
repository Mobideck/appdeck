//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MRImageDownloaderDelegateMF;

@interface MRImageDownloaderMF : NSObject

@property (nonatomic, assign) id<MRImageDownloaderDelegateMF> delegate;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSMutableDictionary *pendingOperations;

- (id)initWithDelegate:(id<MRImageDownloaderDelegateMF>)delegate;
- (void)downloadImageWithURL:(NSURL *)URL;

@end

@protocol MRImageDownloaderDelegateMF <NSObject>

@required
- (void)downloaderDidFailToSaveImageWithURL:(NSURL *)URL error:(NSError *)error;

@end
