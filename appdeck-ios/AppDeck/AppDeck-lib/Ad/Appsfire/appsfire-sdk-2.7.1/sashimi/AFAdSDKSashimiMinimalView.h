/*!
 *  @header    AFAdSDKSashimiMinimalView.h
 *  @abstract  Appsfire Advertising SDK Sashimi Minimal View Header
 *  @version   2.7.0
 */

#import "AFAdSDKSashimiView.h"
#import <UIKit/UILabel.h>

/*!
 * Enum to specify the style mode of the Sashimi view.
 *
 * @since 2.2.0
 */
typedef NS_ENUM(NSUInteger, AFAdSDKSashimiMinimalStyleMode) {
    /*!
     * Light style mode, great for integration in light interfaces.
     *
     * @since 2.2.0
     */
    AFAdSDKSashimiMinimalStyleModeLight = 0,
    
    /*!
     * Dark style mode, great for integration in dark interfaces.
     *
     * @since 2.2.0
     */
    AFAdSDKSashimiMinimalStyleModeDark
};

/*!
 *  `AFAdSDKSashimiMinimalView` is a template advertisement view. It's a very compact view and only
 *  contains essential information.
 */
@interface AFAdSDKSashimiMinimalView : AFAdSDKSashimiView

/*!
 * Content style mode of the sashimi minimal view (Default is `AFAdSDKSashimiMinimalStyleModeLight`).
 *
 * @discussion  When setting this value the default colors of the specified mode will override the
 *              the properties your manually set (colors, blurring, etc..).
 *
 * @since 2.2.0
 */
@property (nonatomic, assign, readwrite) AFAdSDKSashimiMinimalStyleMode styleMode;

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

@end
