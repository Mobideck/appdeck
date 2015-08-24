/*!
 *  @header    AFAdSDKIAP.h
 *  @abstract  Appsfire In-App Purchase Ad Removal Prompt.
 *  @version   2.7.0
 */

#import <Foundation/NSObject.h>
#import <Foundation/NSError.h>
#import "AFAdSDKIAPProperty.h"

/*!
 * Appsfire In-App Purchase Ad Removal prompt class which will alow you display an alert view after:
 *  - a Sushi, Uramaki or an UdonNoodle has been dismissed.
 *  - a Sashimi has been viewed.
 */

@interface AFAdSDKIAP : NSObject

/*!
 * AFAdSDKIAPProperty property setter.
 *
 * @param property The AFAdSDKIAPProperty object used to set the In-App Purchase Ad Removal Prompt 
 * properties. Set to `nil` to disable it. For instance it is necessary to set to `nil` after the 
 * user bought the in-app purchase to remove ads.
 *
 * @param error Pointer to an NSError in case of error.
 *
 * @return `YES` if the AFAdSDKIAPProperty passed in argument is valid. `NO` if the object isn't.
 *
 * @since 2.4.0
 */
+ (BOOL)setProperty:(AFAdSDKIAPProperty *)property andError:(NSError **)error;

/*!
 * Debug mode setter.
 *
 * @param use Setting the debug mode to `YES` ignores the day and count properties and will always show
 * the alert view.
 *
 * @since 2.4.0
 */
+ (void)setDebugModeEnabled:(BOOL)use;

@end
