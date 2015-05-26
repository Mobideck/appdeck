//
//  CustomEventFullscreenDelegate.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 10.03.2014.
//
//

#import <Foundation/Foundation.h>

@class MFCustomEventFullscreen;

@protocol MFCustomEventFullscreenDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;

- (void)customEventFullscreenDidLoadAd:(MFCustomEventFullscreen *)fullscreen;

- (void)customEventFullscreenDidFailToLoadAd;

- (void)customEventFullscreenWillAppear;

- (void)customEventFullscreenWillClose;

- (void)customEventFullscreenWillLeaveApplication;

@end
