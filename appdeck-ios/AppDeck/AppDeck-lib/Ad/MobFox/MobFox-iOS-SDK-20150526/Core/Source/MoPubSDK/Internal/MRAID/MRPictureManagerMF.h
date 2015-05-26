//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRImageDownloaderMF.h"

@protocol MRPictureManagerDelegateMF;

@interface MRPictureManagerMF : NSObject <UIAlertViewDelegate, MRImageDownloaderDelegateMF>

@property (nonatomic, assign) id<MRPictureManagerDelegateMF> delegate;

- (id)initWithDelegate:(id<MRPictureManagerDelegateMF>)delegate;
- (void)storePicture:(NSURL *)url;

@end

@protocol MRPictureManagerDelegateMF <NSObject>

@required
- (void)pictureManager:(MRPictureManagerMF *)manager
        didFailToStorePictureWithErrorMessage:(NSString *)message;

@end
