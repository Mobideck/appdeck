/*!
 *  @header    AFAdSDKSashimiView.h
 *  @abstract  Appsfire Advertising SDK Sashimi Header
 *  @version   2.3.1
 */

#import <UIKit/UIKit.h>
#import "AFAdSDKAdBadgeView.h"

/*! 
 * Information about the type of the screenshot provided by the `screenshotType` property.
 *
 * @since 2.2.0
 */
typedef NS_ENUM(NSUInteger, AFAdSDKAppScreenshotType) {
    /*!
     *  The screenshot type is unknown.
     * 
     * @since 2.2.0
     */
    AFAdSDKAppScreenshotTypeUnknown = 0,
    
    /*!
     *  iPhone screenshot type.
     *
     * @since 2.2.0
     */
    AFAdSDKAppScreenshotTypeiPhone,
    
    /*!
     *  iPad screenshot type.
     *
     * @since 2.2.0
     */
    AFAdSDKAppScreenshotTypeiPad
};

/*!
 * Information about the orientation of the screenshot provided by the `screenshotOrientation` 
 * property.
 *
 * @since 2.2.0
 */
typedef NS_ENUM(NSUInteger, AFAdSDKAppScreenshotOrientation) {
    /*!
     *  The orientation of the screenshot is unknown.
     *
     * @since 2.2.0
     */
    AFAdSDKAppScreenshotOrientationUnknown = 0,
    
    /*!
     *  The screenshot is in Portrait orientation.
     *
     * @since 2.2.0
     */
    AFAdSDKAppScreenshotOrientationPortrait,
    
    /*!
     *  The screenshot is in Landscape orientation.
     *
     * @since 2.2.0
     */
    AFAdSDKAppScreenshotOrientationLandscape
};

/*!
 *  `AFAdSDKSashimiView` is a generic adertisement view containing all the information needed to
 *  create your own sashimi ads.
 */
@interface AFAdSDKSashimiView : UIView

/*! 
 * Title of the application.
 * 
 * @since 2.2.0
 */
@property (nonatomic, readonly) NSString *title;

/*!
 * Tagline of the application.
 *
 * @since 2.2.0
 */
@property (nonatomic, readonly) NSString *tagline;

/*!
 * Localized Category of the application.
 *
 * @since 2.2.0
 */
@property (nonatomic, readonly) NSString *category;

/*!
 * Localized title of the call to action view.
 *
 * @since 2.2.0
 */
@property (nonatomic, readonly) NSString *callToActionTitle;

/*!
 * Icon URL of the application.
 *
 * @since 2.2.0
 */
@property (nonatomic, readonly) NSString *iconURL;

/*!
 * Screenshot URL of the application.
 *
 * @since 2.2.0
 */
@property (nonatomic, readonly) NSString *screenshotURL;

/*!
 * Screenshot Type of the application.
 *
 * @since 2.2.0
 */
@property (nonatomic, readonly) AFAdSDKAppScreenshotType screenshotType;

/*!
 * Screenshot Orientation of the application.
 *
 * @since 2.2.0
 */
@property (nonatomic, readonly) AFAdSDKAppScreenshotOrientation screenshotOrientation;

/*!
 * Is App Free.
 *
 * @since 2.2.0
 */
@property (nonatomic, readonly) BOOL isFree;

/*!
 * Localized price of the application.
 *
 * @since 2.2.0
 */
@property (nonatomic, readonly) NSString *localizedPrice;

/*!
 * The view of the appsfire badge you need to add.
 *
 * @since 2.2.0
 */
@property (nonatomic, readonly) AFAdSDKAdBadgeView *viewAppsfireBadge;

/*!
 *  @brief Called after the view is initialized.
 *
 *  @note You should implement any initialization or user interface thing here.
 *  @note The method will be called before any draw or layout method.
 *
 *  @since 2.2.0
 */
- (void)sashimiIsReadyForInitialization;

@end
