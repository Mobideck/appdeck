/*!
 *  @header    AFAdSDKAdBadgeView.h
 *  @abstract  Appsfire Advertising SDK Ad Badge view.
 *  @version   2.7.0
 */

#import <UIKit/UIView.h>

/*! 
 * Option to specify the style mode of the **Ad badge** view.
 *
 * @since 2.2.0
 */
typedef NS_ENUM(NSUInteger, AFAdSDKAdBadgeStyleMode) {
    /*!
     * Option to set the style mode to light, great for integration in light interfaces.
     * 
     * @since 2.2.0
     */
    AFAdSDKAdBadgeStyleModeLight = 0,

    /*! 
     * Option to set the style mode to dark, great for integration in dark interfaces.
     *
     * @since 2.2.0
     */
    AFAdSDKAdBadgeStyleModeDark
};

/*!
 *  `AFAdSDKAdBadgeView` is a view used to inform end users that they are in an advertisement
 *  situation. To avoid any confusion and mislead the customer.
 * 
 * @note    The recommended size for the badge is `34x14`, if you plan to pick another size, you 
 *          we recommend to get the best fitting size for a given size with the `-sizeThatFits` method.
 */
@interface AFAdSDKAdBadgeView : UIView

/*! 
 * Style mode used by the badge (Default is `AFAdSDKAdBadgeStyleModeLight`).
 *
 * @since 2.2.0
 */
@property (nonatomic, assign, readwrite) AFAdSDKAdBadgeStyleMode styleMode;

@end
