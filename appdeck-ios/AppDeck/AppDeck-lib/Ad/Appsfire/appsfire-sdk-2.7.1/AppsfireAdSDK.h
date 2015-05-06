/*!
 *  @header    AppsfireAdSDK.h
 *  @abstract  Appsfire Advertising SDK Header
 *  @version   2.7.0
 */

#import <UIKit/UIViewController.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSError.h>
#import "AppsfireSDKConstants.h"

@class AFNativeAd;
@class AFAdSDKSashimiView;
@protocol AppsfireAdSDKDelegate;
@protocol AFAdSDKModalDelegate;

/*!
 *  Advertising SDK top-level class.
 */
@interface AppsfireAdSDK : NSObject

/** @name Options
 *  Methods for general options of the library.
 */

/*!
 *  @brief Specify the delegate to handle various interactions with the library.
 *
 *  @param delegate The pointer to the class that will handle the library events, or `nil` if none.
 */
+ (void)setDelegate:(id<AppsfireAdSDKDelegate>)delegate;

/*!
 *  @brief Specify if the library should use the in-app overlay when possible.
 *
 *  @note If the client does not have iOS6+, it will be redirected to the App Store app. By default, this feature is set to `YES`.
 *
 *  @param use A boolean to specify the choice.
 */
+ (void)setUseInAppDownloadWhenPossible:(BOOL)use;

/*!
 *  @brief Specify if the library should be used in debug mode.
 *
 *  @note Whenever this mode is enabled, the web service will return a fake ad.
 *  By default, this mode is disabled. You must decide if you want to enable the debug mode before any prepare/request.
 *
 *  @param use A boolean to specify if the debug mode should be enabled.
 */
+ (void)setDebugModeEnabled:(BOOL)use;


/** @name Modal Ads
 *  Methods for managing Modal Ads.
 */

/*!
 *  @brief Request a modal ad.
 *  @since 2.4
 *
 *  @note If the library isn't initialized, or if the ads aren't loaded yet, then the request will be added to a queue and treated as soon as possible.
 *  You cannot request two ad modals at the same time. In the case where you already have a modal request in the queue, the previous one will be canceled.
 *
 *  @param modalType The kind of modal you want to request.
 *  @param controller A controller that will be used to display the various components. We recommend you specify the root controller or your application.
 *  If you don't specify a controller, the request will be aborted. Note that we'll retain the controller with a strong attribute.
 *  @param delegate (optional) The delegate that will receive any specific event related to your request.
 */
+ (void)requestModalAd:(AFAdSDKModalType)modalType withController:(UIViewController *)controller withDelegate:(id<AFAdSDKModalDelegate>)delegate;

/*!
 *  @brief Ask if ads are loaded and if there is at least one modal ad available.
 *  @since 2.2
 *
 *  @note If ads aren't downloaded yet, then the method will return `AFAdSDKAdAvailabilityPending`.
 *  To test the library, and then have always have a positive response, please use the "debug" mode (see online documentation for more precisions).
 *
 *  @param modalType The kind of modal you want to check.
 *  Note that most of ads should be available for both formats.
 *
 *  @return `AFAdSDKAdAvailabilityPending` if ads aren't loaded yet, `AFAdSDKAdAvailabilityYes` and if there is at least one modal ad available, `AFAdSDKAdAvailabilityNo` otherwise.
 */
+ (AFAdSDKAdAvailability)isThereAModalAdAvailableForType:(AFAdSDKModalType)modalType;

/*!
 *  @brief Force the dismissal of any modal ad currently being displayed on the screen.
 *  @since 2.2.2
 *
 *  @note In the majority of cases, you shouldn't use this method. We highly recommend not to use this method if you aren't sure of the results. Please refer to the documentation or contact us if you have any doubt!
 *
 *  @return `YES` if a modal ad was dismissed, `NO` otherwise.
 */
+ (BOOL)forceDismissalOfModalAd;

/*!
 *  @brief Cancel any pending ad modal request you have made in the past.
 *
 *  @return `YES` if a modal ad was canceled, `NO` otherwise.
 *  If `YES` is returned, you'll get an delegate event via 'modalAdRequestDidFailWithError:'.
 */
+ (BOOL)cancelPendingAdModalRequest;

/*!
 *  @brief Check if there is any modal ad being displayed right now by the library.
 *
 *  @return `YES` if a modal ad is being displayed, `NO` otherwise
 */
+ (BOOL)isModalAdDisplayed;


/** @name Sashimi Ads
 *  Methods for sashimi Ads.
 */

/*!
 *  @brief Get the number of available sashimi ads for a specific format.
 *  @since 2.2
 *
 *  @note If ads aren't downloaded yet, then the method will return `0`.
 *  To test the library, and then have a positive response, please use the "debug" mode.
 *
 *  @param format The kind of sashimi view you would like to get.
 *
 *  @return The number of available sashimi ads.
 */
+ (NSUInteger)numberOfSashimiAdsAvailableForFormat:(AFAdSDKSashimiFormat)format;

/*!
 *  @brief Get the number of available sashimi ads for a specific class.
 *  @since 2.2
 *
 *  @note If ads aren't downloaded yet, then the method will return `0`.
 *  To test the library, and then have a positive response, please use the "debug" mode.
 *
 *  @param viewClass A subclass of `AFAdSDKSashimiView`. Please check the documentation for a good implementation.
 *
 *  @return The number of available sashimi ads.
 */
+ (NSUInteger)numberOfSashimiAdsAvailableForSubclass:(Class)viewClass;

/*!
 *  @brief Get the number of available sashimi ads for a specific nib name.
 *  @since 2.4
 *
 *  @note If ads aren't downloaded yet, then the method will return `0`.
 *  To test the library, and then have a positive response, please use the "debug" mode.
 *
 *  @param nibName A xib which is a subclass of `AFAdSDKSashimiView`. Please check the documentation for a good implementation.
 *
 *  @return The number of available sashimi ads.
 */
+ (NSUInteger)numberOfSashimiAdsAvailableForNibName:(NSString *)nibName;

/*!
 *  @brief Ask if ads are loaded and if there is at least one sashimi ad available.
 *  @since 2.7
 *
 *  @note If ads aren't downloaded yet, then the method will return `AFAdSDKAdAvailabilityPending`.
 *  To test the library, and then have always have a positive response, please use the "debug" mode (see online documentation for more precisions).
 *
 *  @param viewClass A subclass of `AFAdSDKSashimiView`. Please check the documentation for a good implementation.
 *
 *  @return `AFAdSDKAdAvailabilityPending` if ads aren't loaded yet, `AFAdSDKAdAvailabilityYes` and if there is at least one modal ad available, `AFAdSDKAdAvailabilityNo` otherwise.
 */
+ (AFAdSDKAdAvailability)isThereSashimiAdAvailableForSubclass:(Class)viewClass;

/*!
 *  @brief Get a sashimi view based on a format.
 *  @since 2.2
 *
 *  @param format The kind of sashimi view you would like to get.
 *  @param error If a problem occured, the error object will be filled with a code and a description.
 *
 *  @return A view containing an ad which can be displayed right now. In case a problem occured, `nil` could be returned.
 */
+ (AFAdSDKSashimiView *)sashimiViewForFormat:(AFAdSDKSashimiFormat)format andError:(NSError **)error;

/*!
 *  @brief Get a sashimi view based on a subclass.
 *  @since 2.2
 *
 *  @param viewClass A subclass of `AFAdSDKSashimiView`. Please check the documentation for a good implementation.
 *  @param error If a problem occured, the error object will be filled with a code and a description.
 *
 *  @return An `UIView` containing an ad which can be displayed right now. In case a problem occured, `nil` could be returned.
 */
+ (AFAdSDKSashimiView *)sashimiViewForSubclass:(Class)viewClass andError:(NSError **)error;

/*!
 *  @brief Get a sashimi view based on a nib name.
 *  @since 2.4
 *
 *  @param nibName A xib which is a subclass of `AFAdSDKSashimiView`. Please check the documentation for a good implementation.
 *  @param error If a problem occured, the error object will be filled with a code and a description.
 *
 *  @return An `UIView` containing an ad which can be displayed right now. In case a problem occured, `nil` could be returned.
 */
+ (AFAdSDKSashimiView *)sashimiViewForNibName:(NSString *)nibName andError:(NSError **)error;


/** @name Native Ads
 *  Methods for native Ads.
 */

/*!
 *  @brief Ask if ads are loaded and if there is at least one native ad available.
 *  @since 2.7
 *
 *  @note If ads aren't downloaded yet, then the method will return `AFAdSDKAdAvailabilityPending`.
 *  To test the library, and then have always have a positive response, please use the "debug" mode (see online documentation for more precisions).
 *
 *  @return `AFAdSDKAdAvailabilityPending` if ads aren't loaded yet, `AFAdSDKAdAvailabilityYes` and if there is at least one modal ad available, `AFAdSDKAdAvailabilityNo` otherwise.
 */
+ (AFAdSDKAdAvailability)isThereNativeAdAvailable;

/*!
 *  @brief Get the number of available native ads
 *  @since 2.7
 *
 *  @note If ads aren't downloaded yet, then the method will return `0`.
 *  To test the library, and then have a positive response, please use the "debug" mode.
 *
 *  @return The number of available native ads.
 */
+ (NSUInteger)numberOfNativeAdsAvailable;

/*!
 *  @brief Get a native ad.
 *  @since 2.7
 *
 *  @param error If a problem occured, the error object will be filled with a code and a description.
 *
 *  @return A `AFNativeAd` containing a native ad. Please check the documentation for a good implementation!
 */
+ (AFNativeAd *)nativeAdWithError:(NSError **)error;


/** @name Library life
 *  Methods about the general life of the library.
 */

/*!
 *  @brief Ask if ads are loaded from the web service
 *
 *  @note This doesn't necessarily means that an ad is available.
 *  But it's always good to know if you want to debug the implementation and check that the web service responded correctly.
 *
 *  @return `YES` if ads are loaded from the web service.
 */
+ (BOOL)areAdsLoaded;

@end


/*!
 *  Advertising SDK protocol. Provides various events about library life and ads.
 */
@protocol AppsfireAdSDKDelegate <NSObject>

@optional

/** @name Modal Ads
 *  Methods serving modal ads purposes.
 */

/*!
 *  @brief Called when ads were refreshed and that at least one modal ad is available.
 *  @since 2.4
 *
 *  @note You are responsible to check whether there is a modal ad available for the format you are willing to display.
 */
- (void)modalAdsRefreshedAndAvailable;

/*!
 *  @brief Called when ads were refreshed but that none is available for any modal format.
 *  @since 2.4
 *
 *  @note You could decide to act differently knowing that there is currently no ad to display.
 */
- (void)modalAdsRefreshedAndNotAvailable;

/** @name Sashimi Ads
 *  Methods serving sashimi ads purposes.
 */

/*!
 *  @brief Called when ads were refreshed and that at least one sashimi ad is available.
 *  @since 2.4
 *
 *  @note You are responsible to check whether there is a sashimi ad available for the format you are willing to display.
 */
- (void)sashimiAdsRefreshedAndAvailable;

/*!
 *  @brief Called when ads were refreshed but that none is available for any sashimi format.
 *  @since 2.4
 *
 *  @note You could decide to act differently knowing that there is currently no ad to display.
 */
- (void)sashimiAdsRefreshedAndNotAvailable;

/** @name Native Ads
 *  Methods serving native ads purposes.
 */

/*!
 *  @brief Called when ads were refreshed and that at least one native ad is available.
 *  @since 2.7
 */
- (void)nativeAdsRefreshedAndAvailable;

/*!
 *  @brief Called when ads were refreshed but that none is available for native format.
 *  @since 2.7
 *
 *  @note You could decide to act differently knowing that there is currently no ad to display.
 */
- (void)nativeAdsRefreshedAndNotAvailable;

@end


/*!
 *  `AFAdSDKModalDelegate` provides additional information on actions performed on the modal ad.
 */
@protocol AFAdSDKModalDelegate <NSObject>

@optional

/*!
 *  @brief Called when a modal ad is going to be presented on the screen.
 *  Depending the state of your application, you may want to cancel the display of the ad.
 *
 *  @return `YES` if you authorize the ad to display, `NO` if the ad shouldn't display.
 *  If this method isn't implemented, the default value is `YES`.
 *  If you return `NO`, the request will be canceled and an error will be fired through `modalAdRequestDidFailWithError:`
 */
- (BOOL)shouldDisplayModalAd;

/*!
 *  @brief Called when a modal ad failed to present.
 *  You can use the code in the NSError to analyze precisely what went wrong.
 *
 *  @param error The error object filled with the appropriate 'code' and 'localizedDescription'.
 */
- (void)modalAdRequestDidFailWithError:(NSError *)error;

/*!
 *  @brief Called when the modal ad is going to be presented.
 */
- (void)modalAdWillAppear;

/*!
 *  @brief Called when the modal ad was presented.
 */
- (void)modalAdDidAppear;

/*!
 *  @brief Called when the modal ad is going to be dismissed.
 *
 *  @note In case of in-app download, the method is called when the last modal disappears.
 */
- (void)modalAdWillDisappear;

/*!
 *  @brief Called when the modal ad was dismissed.
 */
- (void)modalAdDidDisappear;

@end
