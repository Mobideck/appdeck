//
//  CustomEventFullscreenDelegate.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 10.03.2014.
//
//

#import <Foundation/Foundation.h>

@class CustomEventFullscreen;

@protocol CustomEventFullscreenDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;

- (void)customEventFullscreenDidLoadAd:(CustomEventFullscreen *)fullscreen;

- (void)customEventFullscreenDidFailToLoadAd;

- (void)customEventFullscreenWillAppear;

- (void)customEventFullscreenWillClose;

- (void)customEventFullscreenWillLeaveApplication;

@end
