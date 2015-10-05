/*!
 *  @header    AFAdSDKSashimiExtendedView.h
 *  @abstract  Appsfire Advertising SDK Sashimi Extended View Header
 *  @version   2.7.0
 */

#import "AFAdSDKSashimiView.h"
#import <UIKit/UILabel.h>

/*!
 * Enum to specify the style mode of the Sashimi view
 *
 * @since 2.2.0
 */
typedef NS_ENUM(NSUInteger, AFAdSDKSashimiExtendedStyleMode) {
    /*!
     * Light style mode, great for integration in light interfaces.
     *
     * @since 2.2.0
     */
    AFAdSDKSashimiExtendedStyleModeLight = 0,
    
    /*!
     * Dark style mode, great for integration in dark interfaces.
     *
     * @since 2.2.0
     */
    AFAdSDKSashimiExtendedStyleModeDark
};

/*!
 *  `AFAdSDKSashimiExtendedView` is a template advertisement view, it's a rich template using a part
 *  of the minimal format with a creative on top of it.
 */
@interface AFAdSDKSashimiExtendedView : AFAdSDKSashimiView

/*!
 * Content style mode of the sashimi minimal view (Default is `AFAdSDKSashimiExtendedStyleModeLight`).
 *
 * @discussion  When setting this value the default colors of the specified mode will override the
 *              the properties your manually set (colors, blurring, etc..).
 *
 * @since 2.2.0
 */
@property (nonatomic, assign, readwrite) AFAdSDKSashimiExtendedStyleMode styleMode;

/*!
 * Background color of the view containing the content if the sashimi ad.
 *
 * @since 2.2.0
 */
@property (nonatomic, strong, readwrite) UIColor *contentBackgroundColor;

/*!
 * Color of the border around the app icon.
 *
 * @since 2.3.0
 */
@property (nonatomic, strong, readwrite) UIColor *iconBorderColor;

/*!
 * Edge insets of the whole sashimi view.
 *
 * @since 2.2.0
 */
@property (nonatomic, assign, readwrite) UIEdgeInsets contentInsets;

/*!
 * Label used to represent the title of the application.
 *
 * @since 2.2.0
 */
@property (nonatomic, strong, readwrite) UILabel *titleLabel;

/*!
 * Label used to represent the category of the application.
 *
 * @since 2.2.0
 */
@property (nonatomic, strong, readwrite) UILabel *categoryLabel;

/*!
 * Label used to represent the tagline of the application.
 *
 * @warning The tagline label text can be empty, please check for it's presence before using it if
 *          if you do.
 *
 * @since 2.2.0
 */
@property (nonatomic, strong, readwrite) UILabel *taglineLabel;

/*!
 * Color used to overlay the blurred artwork image.
 *
 * @discussion  For instance, for the `AFAdSDKSashimiExtendedStyleModeLight` style mode the color
 *              is `[UIColor colorWithWhite:1.0 alpha:0.3]` and for the `AFAdSDKSashimiExtendedStyleModeDark`
 *              style mode the color is `[UIColor colorWithWhite:1.0 alpha:0.3]`.
 * 
 * @warning     In the case of custom artwork provided by the advertiser, the overlay color property
 *              is ignored since the overlay view is removed in this case.
 *
 * @since 2.2.0
 */
@property (nonatomic, strong, readwrite) UIColor *artworkBlurOverlayColor;

/*!
 * Radius of the blurred applied to the artwork image.
 *
 * @discussion  Default blur radius is `30`.
 *
 * @warning     In the case of custom artwork provided by the advertiser, the blur radius property 
 *              is ignored since the blurring effect is removed.
 *
 * @since 2.2.0
 */
@property (nonatomic, assign, readwrite) CGFloat blurRadius;

@end
