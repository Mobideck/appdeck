//
//  SASAdViewDelegate.h
//  SmartAdServer
//
//  Created by Clémence Laurent on 23/07/12.
//  Copyright (c) 2012 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 
 The delegate of a SASAdView object must adopt the SASAdViewDelegate protocol.
 
 Many methods of SASAdViewDelegate return the ad view sent by the message.
 The protocol methods allow the delegate to be aware of the ad-related events.
 You can use it to handle your app's or the ad's behavior like adapting your viewController's view size depending on the ad being displayed or not.
 
 */

@class SASAdView, SASAd, SmartAdServerAd;

@protocol SASAdViewDelegate <NSObject>

@optional

///-----------------------------------
/// @name Methods
///-----------------------------------

/** Notifies the delegate that the ad json has been received and fetched and that it will launch its download.
 
 It lets you know what the ad data is so you can adapt your ad behavior. See the SASAd Class Reference for more information.
 
 @param adView The ad view corresponding the SASAd object.
 @param ad A SASAd object.
 
*/

- (void)adView:(SASAdView *)adView didDownloadAd:(SASAd *)ad;


/** *Deprecated* Notifies the delegate that the ad json has been received and fetched and that it will launch its download.
 
 It lets you know what the ad data is so you can adapt your ad behavior. See the SmartAdServerAd Class Reference for more information.
 
 @param adView An ad view informing the delegate about the ad data being fetched.
 @param adData A SmartAdServerAd object.
 
 @warning Deprecated since iOS Display SDK 4.5, please use
 adView:didDownloadAd:
 
 @see adView:didDownloadAd:
 */

- (void)adView:(SASAdView *)adView didDownloadAdData:(SmartAdServerAd *)adData __attribute__((availability(ios,
																										   deprecated=4.5,
																										   message="This method will be removed in the SAS iOS SDK 5.1 and later")));

/** Notifies the delegate that the creative from the current ad has been loaded and displayed.
 
 @param adView An ad view object informing the delegate about the creative being loaded.
 @warning This method is not only called the first time an ad creative is displayed, but also when the user rotates the device, and in a browsable HTML creative, when a new page is loaded.
 
 */

- (void)adViewDidLoad:(SASAdView *)adView;


/** Notifies the delegate that the SASAdView failed to download the ad.
 
 This can happen when the user's connection is interrupted before downloading the ad.
 In this case you might want to:
 
 - refresh the ad view: see [SASBannerView refresh]
 - dismiss the ad view: [SASAdView removeFromSuperview]
 
 @param adView An ad view object informing the delegate about the failure.
 @param error An error informing the delegate about the cause of the failure.
 
 */

- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error;


/** Notifies the delegate that the creative from the current ad has been prefetched in cache.
 
 @param adView An ad view object informing the delegate about the creative being prefetched.
 
 */

- (void)adViewDidPrefetch:(SASAdView *)adView;


/** Notifies the delegate that the SASAdView failed to prefetch the ad in cache.
 
 This can happen when the user's connection is interrupted before downloading the ad.
 In this case you might want to:
 
 - remove the ad view if it's unlimited: [SASAdView removeFromSuperview]
 
 @param adView An ad view object informing the delegate about the failure.
 @param error An error informing the delegate about the cause of the failure.
 
 */

- (void)adView:(SASAdView *)adView didFailToPrefetchWithError:(NSError *)error;


/** Notifies the delegate that the SASAdView which displayed an expandable ad did collapse.
 
 This can happen:
 
 - if the user tapped the toggle button to close the ad
 - after the ad's duration
 
 @param adView An ad view object informing the delegate that it did collapse.
 
 */

- (void)adViewDidCollapse:(SASAdView *)adView;


/** Notifies the delegate that the SASAdView has been dismissed.
 
 This can happen:
 
 - if the user taps the "Skip" button
 - if the ad's duration elapsed
 - if the ad has been clicked
 - if the ad creative decided to close itself
 - if your application decided to remove it by calling [SASInterstitialView removeFromSuperview]
 
 @param adView The ad view informing the delegate that it was dismissed.
 @warning You should not call the adView in this method, except if you want to release it (set your property and the ad's delegate to nil then).
 
 */

- (void)adViewDidDisappear:(SASAdView *)adView;


/** Notifies the delegate that a modal view will appear to display the ad's redirect URL web page if appropriate.
 This won't be called in case of URLs which should not be displayed in a browser like YouTube, iTunes,...
 In this case, it will call adView:shouldHandleURL:.
 
 @param adView The instance of SASAdView displaying the modal view.

 */

- (void)adViewWillPresentModalView:(SASAdView *)adView;


/** Notifies the delegate that the modal view will be dismissed.
 
 @param adView The instance of SASAdView closing the modal view.

 */

- (void)adViewWillDismissModalView:(SASAdView *)adView;


/** Asks the delegate for a View Controller to manage the modal view that displays the redirect URL.
 
 @param adView An ad view object asking the delegate for a UIViewController.
 @return A view controller able to manage the modal view.
 
 */

- (UIViewController *)viewControllerForAdView:(SASAdView *)adView __attribute__((availability(ios,
                                                                                              deprecated=5.0,
                                                                                              message="This method will be removed in future versions")));


/** Notifies the delegate that an ad action has been made (for example the user tapped the ad).
 
 With this method you are informed of the user's action, and you can take appropriate decision (save state, launch your introduction video,...).
 
 @param adView An ad view object informing the delegate about the ad being clicked.
 @param willExit Whether the user chooses to leave the app.
 
 */

- (void)adView:(SASAdView *)adView willPerformActionWithExit:(BOOL)willExit;


/** Asks the delegate whether to execute the ad action.
 
 Implement this method if you want to process some URLs yourself.
 
 @param adView An ad view object informing the delegate about the ad responsible for the click.
 @param URL The URL that will be called.
 @return Whether the Smart AdServer SDK should handle the URL.
 @warning Returning NO means that the URL won't be processed by the SDK.
 @warning Please note that a click will be counted, even if you return NO (you are supposed to handle the URL in this case).
 
 */

- (BOOL)adView:(SASAdView *)adView shouldHandleURL:(NSURL *)URL;


/** Returns the animations used to dismiss the ad view.
 
 @param adView The ad view to be dismissed.
 @return The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
 
 */

- (NSTimeInterval)animationDurationForDismissingAdView:(SASAdView *)adView;


/** Returns the animations used to dismiss the ad view.
 
 @param adView The ad view to be dismissed.
 @return A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions.
 
 */

- (UIViewAnimationOptions)animationOptionsForDismissingAdView:(SASAdView *)adView;


// MRAID Delegate Methods

/** Notifies the delegate that the ad view is about to be resized.
 
 @param adView The ad view to be resized.
 @param frame The frame of the ad view before resizing it.
 @warning This method is not only called the first time an ad creative is resized, but also when the user rotates the device.
 
 */

- (void)adView:(SASAdView *)adView willResizeWithFrame:(CGRect)frame;


/** Notifies the delegate that the ad view was resized.
 
 @param adView The resized ad view.
 @param frame The frame of the ad view after resizing it.
 @warning This method is not only called the first time an ad creative is resized, but also when the user rotates the device.
 
 */

- (void)adView:(SASAdView *)adView didResizeWithFrame:(CGRect)frame;


/** Notifies the delegate that the ad view was resized.
 
 @param adView The ad view that failed to resize.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. 
 You may specify nil for this parameter if you do not want the error information.
 
 */
- (void)adViewDidFailToResize:(SASAdView *)adView error:(NSError *)error;


/** Notifies the delegate that the resized ad was closed.
 
 @param adView The resized ad view that was closed.
 @param frame The frame of the ad view after closing it.
 
 */

- (void)adView:(SASAdView *)adView didCloseResizeWithFrame:(CGRect)frame;


/** *Deprecated* Notifies the delegate that the ad view is about to be expanded.
 
 @param adView The ad view to be expanded.
 @param frame The frame of the ad view before expanding.
 @warning This method is not only called the first time an ad creative is expanded, but also when the user rotates the device.
 
 @warning Deprecated since iOS Display SDK 4.5, please use
 adViewWillExpand:
 
 @see adViewWillExpand:
 */

- (void)adView:(SASAdView *)adView willExpandWithFrame:(CGRect)frame __attribute__((availability(ios,
																								 deprecated=4.5,
																								 message="This method will be removed in the SAS iOS SDK 5.1 and later")));


/** Notifies the delegate that the ad view is about to be expanded.
 
 @param adView The ad view to be expanded.
 @warning This method is not only called the first time an ad creative is expanded, but also when the user rotates the device.
 
 */

- (void)adViewWillExpand:(SASAdView *)adView;


/** Notifies the delegate that the ad view was expanded.
 
 @param adView The expanded ad view.
 @param frame The frame of the ad view after expanding.
 @warning This method is not only called the first time an ad creative is expanded, but also when the user rotates the device.
 
 */

- (void)adView:(SASAdView *)adView didExpandWithFrame:(CGRect)frame;


/** Notifies the delegate that the expanded ad was closed.
 
 @param adView The expanded ad view that was closed.
 @param frame The frame of the ad view after closing.
 
 */

- (void)adView:(SASAdView *)adView didCloseExpandWithFrame:(CGRect)frame;


/** Notifies the delegate that the ad view received a message from the MRAID creative.
 
 Creatives can send messages using mraid.sasSendMessage("message"). These messages are sent to the ad view delegate by the SDK.
 Please note that this method IS NOT PART of MRAID 2.0 specification.
 
 @param adView The receiver ad view.
 @param message The message sent by the creative.
 
 */

- (void)adView:(SASAdView *)adView didReceiveMessage:(NSString *)message;

@end
