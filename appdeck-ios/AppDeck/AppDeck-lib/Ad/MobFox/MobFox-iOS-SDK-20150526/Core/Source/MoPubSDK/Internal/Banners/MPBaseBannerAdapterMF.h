//
//  MPBaseBannerAdapter.h
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MPAdViewMF.h"

@protocol MPBannerAdapterDelegateMF;
@class MPAdConfigurationMF;

@interface MPBaseBannerAdapterMF : NSObject
{
    id<MPBannerAdapterDelegateMF> _delegate;
}

@property (nonatomic, assign) id<MPBannerAdapterDelegateMF> delegate;
@property (nonatomic, copy) NSURL *impressionTrackingURL;
@property (nonatomic, copy) NSURL *clickTrackingURL;

- (id)initWithDelegate:(id<MPBannerAdapterDelegateMF>)delegate;

/*
 * Sets the adapter's delegate to nil.
 */
- (void)unregisterDelegate;

/*
 * -_getAdWithConfiguration wraps -getAdWithConfiguration in retain/release calls to prevent the
 * adapter from being prematurely deallocated.
 */
- (void)getAdWithConfiguration:(MPAdConfigurationMF *)configuration containerSize:(CGSize)size;
- (void)_getAdWithConfiguration:(MPAdConfigurationMF *)configuration containerSize:(CGSize)size;

- (void)didStopLoading;
- (void)didDisplayAd;

/*
 * Your subclass should implement this method if your native ads vary depending on orientation.
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;

- (void)trackImpression;

- (void)trackClick;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPBannerAdapterDelegateMF

@required

- (MPAdViewMF *)banner;
- (id<MPAdViewDelegateMF>)bannerDelegate;
- (UIViewController *)viewControllerForPresentingModalView;
- (MPNativeAdOrientation)allowedNativeAdsOrientation;
- (CLLocation *)location;

/*
 * These callbacks notify you that the adapter (un)successfully loaded an ad.
 */
- (void)adapter:(MPBaseBannerAdapterMF *)adapter didFailToLoadAdWithError:(NSError *)error;
- (void)adapter:(MPBaseBannerAdapterMF *)adapter didFinishLoadingAd:(UIView *)ad;

/*
 * These callbacks notify you that the user interacted (or stopped interacting) with the native ad.
 */
- (void)userActionWillBeginForAdapter:(MPBaseBannerAdapterMF *)adapter;
- (void)userActionDidFinishForAdapter:(MPBaseBannerAdapterMF *)adapter;

/*
 * This callback notifies you that user has tapped on an ad which will cause them to leave the
 * current application (e.g. the ad action opens the iTunes store, Mobile Safari, etc).
 */
- (void)userWillLeaveApplicationFromAdapter:(MPBaseBannerAdapterMF *)adapter;

@end
