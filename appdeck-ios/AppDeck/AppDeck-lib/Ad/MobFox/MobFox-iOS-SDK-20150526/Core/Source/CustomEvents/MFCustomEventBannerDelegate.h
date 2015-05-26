//
//  CustomEventBannerDelegate.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 20.02.2014.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MFCustomEventBanner;

@protocol MFCustomEventBannerDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;

- (void)customEventBannerDidLoadAd:(UIView *)ad;

- (void)customEventBannerDidFailToLoadAd;

- (void)customEventBannerWillExpand;

- (void)customEventBannerWillClose;


@end
