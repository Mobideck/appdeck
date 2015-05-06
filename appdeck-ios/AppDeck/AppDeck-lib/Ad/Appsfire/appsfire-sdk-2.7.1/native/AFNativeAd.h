/*!
 *  @header    AFNativeAd.h
 *  @abstract  Appsfire Advertising SDK Native Ad Header
 *  @version   2.7.1
 */

#import <Foundation/NSObject.h>
#import <UIKit/UIView.h>

@protocol AFNativeAdDelegate;

/*!
 *  `AFNativeAd` is a generic adertisement object containing all the information needed to create your own native ads.
 */
@interface AFNativeAd : NSObject

/*!
 * The object that acts as the delegate of the receiving native ad.
 */
@property (nonatomic, weak) id <AFNativeAdDelegate> delegate;

/*!
 *  Title of the ad.
 */
@property (nonatomic, copy, readonly) NSString *title;

/*!
 *  Tagline of the ad.
 */
@property (nonatomic, copy, readonly) NSString *tagline;

/*!
 *  Call to action of the ad.
 */
@property (nonatomic, copy, readonly) NSString *callToAction;

/*!
 *  Icon URL of the ad.
 */
@property (nonatomic, copy, readonly) NSString *iconURL;

/*!
 *  Screenshot URL of the ad.
 */
@property (nonatomic, copy, readonly) NSString *screenshotURL;

/*!
 *  The star rating of the ad (out of 5).
 */
@property (nonatomic, copy, readonly) NSNumber *starRating;

/*!
 *  Localized category of the application.
 */
@property (nonatomic, copy, readonly) NSString *category;


/*!
 *  @brief Connect the `AFNativeAd` object to the view you use for display.
 *
 *  @note Calling this method more than one time cancels any previous call.
 *
 *  @param view The view you use to render the ad.
 *  @param clickableViews (optional) An array of views (e.g. CTA button) that will be used for observing the clicks. By default the the first parameter will be used instead.
 */
- (void)connectViewForDisplay:(UIView *)view withClickableViews:(NSArray *)clickableViews;

/*!
 *  @brief Disconnect the `AFNativeAd` object with any previous connection.
 */
- (void)disconnectViewForDisplay;

/*!
 *  @brief Download an asset asynchronously.
 *
 *  @param assetURL The url of the asset you would like to download. It should be either the icon or the screenshot, or it'll fail.
 *  @param completion The completion block for the callback once the asset is downloaded. If a problem occured, the `image` variable will be `nil`. Note: the block is called on the main thread.
 */
- (void)downloadAsset:(NSString *)assetURL completion:(void (^)(UIImage *image))completion;

@end

/*!
 * `AFNativeAdDelegate` provides additional information on actions performed on the native ad.
 */
@protocol AFNativeAdDelegate <NSObject>

@optional

/*!
 * @brief This delegate event informs you that the Appsfire SDK has recorded an impression on the view connected to the native ad.
 *
 * @param nativeAd The `AFNativeAd` object sending the message.
 */
- (void)nativeAdDidRecordImpression:(AFNativeAd *)nativeAd;

/*!
 *  @brief This delegate event informs you that the Appsfire SDK has recorded a click on the view connected to the native ad.
 *
 *  @param nativeAd The `AFNativeAd` object sending the message.
 */
- (void)nativeAdDidRecordClick:(AFNativeAd *)nativeAd;

/*!
 *  @brief This delegate event informs you that an overlay will be added on top of the current view controller. You will not be able to interact with your interface until the end of the presentation and you may want to pause certain actions at this moment.
 *
 *  @param nativeAd The `AFNativeAd` object sending the message.
 */
- (void)nativeAdBeginOverlayPresentation:(AFNativeAd *)nativeAd;

/*!
 *  @brief This delegate event informs you that the overlay that was presented has been removed and you will be able to re-interact with your interface. You may want to resume any action you paused during the process.
 *
 *  @param nativeAd The `AFNativeAd` object sending the message.
 */
- (void)nativeAdEndOverlayPresentation:(AFNativeAd *)nativeAd;

/*!
 *  @brief This method should return the UIViewController used to host the StoreKit view controller. If not implemented, the StoreKit is not used and the user will be redirected to the App Store to download the app.
 *
 *  @param nativeAd The `AFNativeAd` object requesting for the host UIViewController to contain the StoreKit.
 *
 *  @return a UIViewController that will host the StoreKit.
 */
- (UIViewController *)viewControllerForNativeAd:(AFNativeAd *)nativeAd;

@end
