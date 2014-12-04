//
//  SASInterstitialView.h
//  SmartAdServer
//
//  Created by Clémence Laurent on 09/03/12.
//  Copyright (c) 2012 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASAdView.h"
#import "SASAdViewDelegate.h"

/** The SASInterstitialView class provides a wrapper view that displays an ad interstitial to the user.
 
 When the user taps a SASInterstitialView instance, the view triggers an action programmed into the advertisement.
 For example, an advertisement might, present a modal advertisement, show a movie, or launch a third party application (Safari, the App Store, YouTube...).
 Your application is notified by the **SASAdViewDelegate protocol** methods which are called during the ad's lifecycle.
 You can interact with the view by 
 
 - refreshing it: refresh
 - removing it: removeFromSuperView
 
 The delegate of a SASInterstitialView object must adopt the SASAdViewDelegate protocol.
 The protocol methods allow the delegate to be aware of the ad-related events.
 You can use it to handle your app's or the ad's (the SASInterstitialView instance) behavior like adapting your viewController's view size depending on the ad being displayed or not.
 
 */

@class SASAd;
@interface SASInterstitialView : SASAdView

///---------------------------------------
/// @name Ad interstitial view properties
///---------------------------------------


/**  The object that acts as the delegate of the receiving ad interstitial view.
 
 The delegate must adopt the SASAdViewDelegate protocol.
 This must be the view controller actually controlling the view displaying the ad, not a view controller just designed to handle the ad logic.
 
 @warning *Important* : The delegate is not retained by the SASInterstitialView instance, so you need to set the ad's delegate to nil before the delegate is killed.
 
 */

@property (nonatomic, assign) UIViewController <SASAdViewDelegate> *delegate;


///-----------------------------------------
/// @name Creating an insterstitial view
///-----------------------------------------


/** Initializes and returns a SASInterstitialView object for the given frame.
 
 @param frame A rectangle specifying the initial location and size of the ad interstitial view in its superview's coordinates.
 The frame of the table view changes when it loads an expand format.
 
 */

- (id)initWithFrame:(CGRect)frame;

/** Initializes and returns a SASInterstitialView object for the given frame, and optionally sets a loader on it.
 
 @param frame A rectangle specifying the initial location and size of the ad interstitial view in its superview's coordinates. The frame of the table view changes when it loads an expand format. 
 @param loaderType A SASLoader value that determines whether the view should display a loader or not while downloading the ad.
 SASLoader can take the following values: SASLoaderNone, SASLoaderLaunchImage, SASLoaderActivityIndicatorStyleBlack, SASLoaderActivityIndicatorStyleWhite, SASLoaderActivityIndicatorStyleTransparent.
 
 */

- (id)initWithFrame:(CGRect)frame loader:(SASLoader)loaderType;

/** Initializes and returns a SASInterstitialView object for the given frame, and optionally sets a loader on it and hides the status bar.
 
 You can use this method to display an interstitial in full screen mode, even if you have a status bar. The ad interstitial view will remove the status bar, and replace it when the ad duration is over, or when the user dimisses the ad by taping on it, or on the skip button.
 
 @param frame A rectangle specifying the initial location and size of the ad interstitial in its superview's coordinates. The frame of the table view changes when it loads an expand format. 
 @param loaderType A SASLoader value that determines whether the view should display a loader or not while downloading the ad.
 SASLoader can take the following values: SASLoaderNone, SASLoaderLaunchImage, SASLoaderActivityIndicatorStyleBlack, SASLoaderActivityIndicatorStyleWhite, SASLoaderActivityIndicatorStyleTransparent.
 @param hideStatusBar A boolean value indicating the SASInterstitialView object to auto hide the status bar if needed when the ad is displayed.
 @warning Your application should support auto-resizing without the status bar. Some ads can have a transparent background, and if your application doesn't resize, the user will see a blank 20px frame on top of your app. 
 
 */

- (id)initWithFrame:(CGRect)frame loader:(SASLoader)loaderType hideStatusBar:(BOOL)hideStatusBar;


///-----------------------------------
/// @name Prefetching an interstitial
///-----------------------------------

/** Prefetches an interstitial from Smart AdServer cache in offline or online mode.
 
 Call this method after initializing your SASInterstitialView object with an initWithFrame: to load the appropriate SASAd object from the server and display the previously prefetched ad.
 The SASInterstitialView will fail, and notify the delegate if the timeout expires.
 
 @param formatId The format ID in the Smart AdServer manage interface.
 @param pageId The page ID in the Smart AdServer manage interface.
 @param isMaster The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, and NO for the others (if you have more than one ad on the same page).
 @param target If you specified targets in the Smart AdServer manage interface, you can send it here to target your advertisement.
 
 */

- (void)prefetchFormatId:(NSInteger)formatId pageId:(NSString *)pageId master:(BOOL)isMaster target:(NSString *)target;


///-------------------------------------------------
/// @name Interacting with the interstitial view
///-------------------------------------------------


/** *Deprecated* Gives an ad for the interstitial view to display.
 
 Use this method if you want your application to provide a local SmartAdServerAd (usually in case of error).
 
 @param adInterstitial A SmartAdServerAd created by your application. This object is retained by the ad interstitial view.
 
 */

- (void)displayThisAd:(SmartAdServerAd *)adInterstitial __attribute__((deprecated));

@end
