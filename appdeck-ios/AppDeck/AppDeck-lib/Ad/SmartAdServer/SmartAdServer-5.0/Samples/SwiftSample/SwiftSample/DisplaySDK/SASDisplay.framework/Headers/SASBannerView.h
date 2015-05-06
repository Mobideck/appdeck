//
//  SASBannerView.h
//  SmartAdServer
//
//  Created by Clémence Laurent on 09/03/12.
//  Copyright (c) 2012 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASAdView.h"
#import "SASAdViewDelegate.h"

#define kSASRefreshIntervalOff		(-1)
#define kSASRefreshIntervalMiminum	20

/** The SASBannerView class provides a wrapper view that displays an ad banner to the user.
 
 When the user taps a SASBannerView instance, the view triggers an action programmed into the advertisement.
 For example, an advertisement might, present a modal advertisement, show a movie, or launch a third party application (Safari, the App Store, YouTube...).
 Your application is notified by the **SASAdViewDelegate protocol** methods which are called during the ad's lifecycle.
 You can interact with the view by:
 
 - refreshing it: refresh
 - removing it: removeFromSuperView
 
 The delegate of a SASBannerView object must adopt the SASAdViewDelegate protocol.
 The protocol methods allow the delegate to be aware of the ad-related events.
 You can use it to handle your app's or the ad's (the SASBannerView instance) behavior like adapting your viewController's view size depending on the ad being displayed or not.
 
 */

//@class SASAd;
@interface SASBannerView : SASAdView


///-----------------------------------
/// @name Ad banner view properties
///-----------------------------------


/** The object that acts as the delegate of the receiving ad banner view.
 
 The delegate must adopt the SASAdViewDelegate protocol.
 This must be the view controller actually controlling the view displaying the ad, not a view controller just designed to handle the ad logic.
 
 @warning *Important* : The delegate is not retained by the SASBannerView instance, so you need to set the ad's delegate to nil before the delegate is killed.
 
 */

@property (nonatomic, assign) UIViewController <SASAdViewDelegate> *delegate;

/** Whether the ad banner should expand from the top to the bottom.
 
 On a banner placement, "expand" formats can be loaded. 
 This will cause the view to resize itself in an animated way. If you place your banner at the top of your view, set this property to YES, if you place it at the bottom, set it to NO.
 
 */

@property (assign) BOOL expandsFromTop;

/**
 * Starts or stops the auto refresh of ads on this SASBannerView by setting
 * the refresh interval in seconds. The refresh interval cannot be less than
 * kSASRefreshIntervalMiminum (20 seconds)
 * By default, the refresh interval is set to kSASRefreshIntervalOff.
 *
 */

@property (nonatomic, assign) NSInteger refreshInterval;

///-----------------------------------
/// @name Creating a banner view
///-----------------------------------


/** Initializes and returns a SASBannerView object for the given frame
 
 @param frame A rectangle specifying the initial location and size of the ad banner view in its superview's coordinates. 
 The frame of the table view changes when it loads an expand format.
 
 */

- (id)initWithFrame:(CGRect)frame;

/** Initializes and returns a SASBannerView object for the given frame, and optionally sets a loader on it.
 
 @param frame A rectangle specifying the initial location and size of the ad banner view in its superview's coordinates. The frame of the table view changes when it loads an expand format. 
 @param loaderType A SASLoader value that determines whether the view should display a loader or not while downloading the ad.
 SASLoader can take the following values: SASLoaderNone, SASLoaderLaunchImage, SASLoaderActivityIndicatorStyleBlack, SASLoaderActivityIndicatorStyleWhite, SASLoaderActivityIndicatorStyleTransparent.
 
 */

- (id)initWithFrame:(CGRect)frame loader:(SASLoader)loaderType;


/** Whether the ad should stay in place (more often for a banner) or be removed after a certain duration.
 
 @param isPermanent A boolean specifying wether 
 */

- (void)bannerDisplayIsPermanent:(BOOL)isPermanent;

///-----------------------------------
/// @name Refreshing a banner
///-----------------------------------

/** Updates the banner view.
 
 Call this method to fetch a new banner from Smart AdServer with the same settings you provided with loadFormatId:pageId:master:target:
 This will set the master flag to NO, because you probably don't want to count a new page view.
 
 */

- (void)refresh;


///-------------------------------------------
/// @name Interacting with the banner view
///-------------------------------------------

/** *Deprecated* Gives an ad for the banner view to display.
 Use this method if you want your application to provide a local SmartAdServerAd (usually in case of error).
 
 @param adBanner A SmartAdServerAd created by your application. This object is retained by the ad banner view.
 
 */

- (void)displayThisAd:(SASAd *)adBanner __attribute__((deprecated));

@end
