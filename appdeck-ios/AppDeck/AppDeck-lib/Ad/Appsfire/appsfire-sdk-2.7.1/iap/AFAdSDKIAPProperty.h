/*!
 *  @header    AFAdSDKIAPProperty.h
 *  @abstract  Appsfire In-App Purchase Ad Removal Prompte property class.
 *  @version   2.7.0
 */

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

/*!
 * In-App Purchase Ad Removal Prompte property class.
 */
@interface AFAdSDKIAPProperty : NSObject

/*!
 * String used in the title of the UIAlertView.
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, copy) NSString *title;

/*!
 * String used in the message of the UIAlertView.
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, copy) NSString *message;

/*!
 * String used in the "Cancel" button of the UIAlertView
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, copy) NSString *cancelButtonTitle;

/*!
 * String used in the "Buy" button of the UIAlertView. It is advised to add the price next the the
 * "Buy" action. Example: "Buy ($0.99)".
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, copy) NSString *buyButtonTitle;

/*!
 * The block called after the user tapped on the "Buy" button.
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, copy) void (^buyBlock)(void);

/*!
 * Boolean value whether the reminding mechanism should be used. Default is `YES`.
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, assign) BOOL shouldRemind;

/*!
 * Number of days until the first UIAlertView is displayed. If you want to disable this parameter
 * and only consider the `dismissCountUntil*` parameter, just set this parameter to `0`.
 * 
 * @note Default is `7`.
 *
 * @note If the number of days is reached, the UIAlertView will only be displayed if the value of
 * dismissCountUntilFirstPromptModal, dismissCountUntilFirstPromptSashimi or
 * dismissCountUntilFirstPromptUdonNoodle is also reached.
 *
 * @see dismissCountUntilFirstPromptModal
 * @see displayCountUntilFirstPromptSashimi
 * @see dismissCountUntilFirstPromptUdonNoodle
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, assign) NSUInteger daysCountUntilFirstPrompt;

/*!
 * Number of days before displaying the UIAlertView again after the user tapped on the "Cancel"
 * button.
 *
 * @note This parameter is only taken into account if the parameter `shouldRemind` is set to `YES`.
 * If you want to disable this parameter and only consider the `dismissCountBefore*` parameter, just
 * set this parameter to `0`.
 *
 * @note Default is `7`.
 *
 * @see shouldRemind
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, assign) NSUInteger daysCountBeforeReminding;

/*!
 * Number of times modal ads like Sushi or Uramaki are dismissed and after which the first 
 * UIAlertView should be displayed.
 *
 * @note If the dismiss count is reached, the UIAlertView will only be displayed if the value of 
 * daysCountUntilFirstPrompt is also reached. If you want to disable this parameter and only 
 * consider the `daysCountUntil*` parameter, just set this parameter to `0`.
 *
 * @note Default is `10`.
 *
 * @see daysCountUntilFirstPrompt
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, assign) NSUInteger dismissCountUntilFirstPromptModal;

/*!
 * Number of modal dismiss before displaying the UIAlertView again after the user tapped on the
 * "Cancel" button.
 *
 * @note This parameter is only taken into account if the parameter `shouldRemind` is set to `YES`.
 * If you want to disable this parameter and only consider the daysCountBeforeReminding parameter, 
 * just set this parameter to `0`.
 *
 * @note Default is `10`.
 *
 * @see shouldRemind
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, assign) NSUInteger dismissCountBeforeRemindingModal;

/*!
 * Number of Sashimi display after which first the UIAlertView should be displayed.
 *
 * @note If the display count is reached, the UIAlertView will only be displayed if the value of 
 * daysCountUntilFirstPrompt is also reached. If you want to disable this parameter and only 
 * consider the daysCountUntilFirstPrompt parameter, just set this parameter to `0`.
 *
 * @note Default is `100`.
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, assign) NSUInteger displayCountUntilFirstPromptSashimi;

/*!
 * Number of Sashimi display before showing again the UIAlertView after the user tapped on the
 * "Cancel" button.
 *
 * @note If the display count is reached, the UIAlertView will only be displayed if the value of
 * daysCountBeforeReminding is also reached. If you want to disable this parameter and only consider
 * the daysCountBeforeReminding parameter, just set this parameter to `0`.
 *
 * @note Default is `100`.
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, assign) NSUInteger displayCountBeforeRemindingSashimi;

/*!
 * Number of times Udon Noodle is dismissed and after which the first UIAlertView should be 
 * displayed.
 *
 * @note If the dismiss count is reached, the UIAlertView will only be displayed if the value of
 * daysCountUntilFirstPrompt is also reached. If you want to disable this parameter and only
 * consider the `daysCountUntil*` parameter, just set this parameter to `0`.
 * 
 * @note Default is `10`.
 *
 * @see daysCountUntilFirstPrompt
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, assign) NSUInteger dismissCountUntilFirstPromptUdonNoodle;

/*!
 * Number of Udon Noodle dismiss before displaying the UIAlertView again after the user tapped on 
 * the "Cancel" button.
 *
 * @note This parameter is only taken into account if the parameter `shouldRemind` is set to `YES`.
 * If you want to disable this parameter and only consider the daysCountBeforeReminding parameter,
 * just set this parameter to `0`.
 * 
 * @note Default is `10`.
 *
 * @see shouldRemind
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, assign) NSUInteger dismissCountBeforeRemindingUdonNoodle;

/*!
 * Number of Himono banner display after which first the UIAlertView should be displayed.
 *
 * @note If the display count is reached, the UIAlertView will only be displayed if the value of
 * daysCountUntilFirstPrompt is also reached. If you want to disable this parameter and only
 * consider the daysCountUntilFirstPrompt parameter, just set this parameter to `0`.
 *
 * @note Default is `100`.
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, assign) NSUInteger displayCountUntilFirstPromptHimono;

/*!
 * Number of Himono banner display before showing again the UIAlertView after the user tapped on the
 * "Cancel" button.
 *
 * @note If the display count is reached, the UIAlertView will only be displayed if the value of
 * daysCountBeforeReminding is also reached. If you want to disable this parameter and only consider
 * the daysCountBeforeReminding parameter, just set this parameter to `0`.
 *
 * @note Default is `100`.
 *
 * @since 2.4.0
 */
@property (readwrite, nonatomic, assign) NSUInteger displayCountBeforeRemindingHimono;

/*!
 * AFAdSDKIAPProperty Property builder.
 *
 * @param block The block used to configure the property on creation.
 *
 * @return The newly created instance configured by block.
 * 
 * @note A newly created instance is only mutable in the scope of block. Once constructed, a 
 * property becomes immutable.
 *
 * @since 2.4.0
 */
+ (instancetype)propertyWithBlock:(void(^)(AFAdSDKIAPProperty *property))block;

@end
