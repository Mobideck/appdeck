//
//  CustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 10.03.2014.
//
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MFCustomEventFullscreenDelegate.h"

@interface MFCustomEventFullscreen : NSObject

- (void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel;

- (void)showFullscreenFromRootViewController:(UIViewController *)rootViewController;

- (void)notifyAdFailed;

- (void)notifyAdLoaded;

- (void)notifyAdWillAppear;

- (void)notifyAdWillClose;

- (void)notifyAdWillLeaveApplication;

- (void)finish;


@property (nonatomic, assign) id<MFCustomEventFullscreenDelegate> delegate;
@property (nonatomic, retain) NSString* trackingPixel;

@end
