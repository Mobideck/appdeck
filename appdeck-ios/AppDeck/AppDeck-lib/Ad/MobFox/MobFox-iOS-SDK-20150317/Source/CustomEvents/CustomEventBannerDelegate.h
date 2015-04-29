//
//  CustomEventBannerDelegate.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 20.02.2014.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CustomEventBanner;

@protocol CustomEventBannerDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;

- (void)customEventBannerDidLoadAd:(UIView *)ad;

- (void)customEventBannerDidFailToLoadAd;

- (void)customEventBannerWillExpand;

- (void)customEventBannerWillClose;


@end
