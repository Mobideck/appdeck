/*!
 *  @header    AppsfireSDKConstants.h
 *  @abstract  Appsfire SDK Constants Header
 *  @version   2.7.0
 */

#import <Foundation/NSObject.h>
#include <CoreGraphics/CGGeometry.h>

/*!
 *  @brief Names of parameters you can use in the initialization method.
 *  @since 2.4
 */

/** initialization delay. must be a NSNumber */
extern NSString* const kAFSDKInitDelay;


/*!
 *  @brief Names of notifications you can observe in Appsfire SDK.
 *  @since 2.0
 */

/** sdk is initializing */
extern NSString* const kAFSDKIsInitializing;

/** sdk is initialized */
extern NSString* const kAFSDKIsInitialized;

/** notifications count was updated */
extern NSString* const kAFSDKNotificationsNumberChanged;

/** panel (for notifications or feedback) was presented */
extern NSString* const kAFSDKPanelWasPresented;

/** panel (for notifications or feedback) was dismissed */
extern NSString* const kAFSDKPanelWasDismissed;


/*!
 *  @brief Names of notifications for the availability of ads.
 *  @since 2.7
 */

/** modal ads were refreshed and at least one is available */
extern NSString* const kAFSDKModalAdsRefreshedAndAvailable;

/** modal ads were refreshed but none is available */
extern NSString* const kAFSDKModalAdsRefreshedAndNotAvailable;

/** sashimi ads were refreshed and at least one is available */
extern NSString* const kAFSDKSashimiAdsRefreshedAndAvailable;

/** sashimi ads were refreshed but none is available */
extern NSString* const kAFSDKSashimiAdsRefreshedAndNotAvailable;

/** native ads were refreshed and at least one is available */
extern NSString* const kAFSDKNativeAdsRefreshedAndAvailable;

/** native ads were refreshed but none is available */
extern NSString* const kAFSDKNativeAdsRefreshedAndNotAvailable;


/*!
 *  @brief Predefined heights of the banner in full width case.
 *  @since 2.7
 */

/** iPhone banner height of 50pt */
extern CGFloat const kAFAdSDKBannerHeight50;

/** iPad banner height of 90pt */
extern CGFloat const kAFAdSDKBannerHeight90;


/*!
 *  @brief Enum for specifying features you plan to use.
 *
 *  @note By specifying us the list of features you plan using, you'll allow us to optimize the user experience and the web-services calls.
 *  Default value is all features.
 *
 *  @since 2.2
 */
typedef NS_OPTIONS(NSUInteger, AFSDKFeature) {
    /** Engage feature */
    AFSDKFeatureEngage          = 1 << 0,
    /** Monetization feature */
    AFSDKFeatureMonetization    = 1 << 1
};


/*!
 *  @brief Enum for deciding the presentation style of the panel (engage sdk).
 *
 *  @note Embedded display allows users to see your application behind.
 *  Fullscreen is like its name, users won't see your application and will be immersed into the sdk.
 *
 *  @since 2.0
 */
typedef NS_ENUM(NSUInteger, AFSDKPanelStyle) {
    /** Display on part of the screen so your app is visible behind */
    AFSDKPanelStyleDefault,
    /** Display on the whole screen (iPhone/iPod only) */
    AFSDKPanelStyleFullscreen
};


/*!
 *  @brief Enum for deciding the content type of the panel (engage sdk).
 *  @since 2.0
 *
 *  @note Default displays by default the notifications, but the user can send a feedback too thanks to a button.
 *  'Feedback only' will directly display the feedback form, user won't be able to see notifications list.
 */
typedef NS_ENUM(NSUInteger, AFSDKPanelContent) {
    /** Display notifications wall */
    AFSDKPanelContentDefault,
    /** Display the feedback form only */
    AFSDKPanelContentFeedbackOnly
};


/*!
 *  @brief Enum for specifying the modal type (monetization sdk).
 *  @since 2.1
 */
typedef NS_ENUM(NSUInteger, AFAdSDKModalType) {
    /** A native fullscreen ad */
    AFAdSDKModalTypeSushi = 0,
    /** An interstitial, with experience similar to the task manager in iOS7, except it happens within the publisher app */
    AFAdSDKModalTypeUraMaki = 1
};


/*!
 *  @brief Enum for specifying the sashimi format (monetization sdk).
 *  @since 2.2
 */
typedef NS_ENUM(NSUInteger, AFAdSDKSashimiFormat) {
    /**  */
    AFAdSDKSashimiFormatMinimal = 0,
    /**  */
    AFAdSDKSashimiFormatExtended = 1
};


/*!
 *  @brief Enum for specifying the ad availability (monetization sdk).
 *  @since 2.2
 */
typedef NS_ENUM(NSUInteger, AFAdSDKAdAvailability) {
    /** Answer can't be given right now */
    AFAdSDKAdAvailabilityPending = 0,
    /** An ad is available right now */
    AFAdSDKAdAvailabilityYes = 1,
    /** An ad isn't available right now */
    AFAdSDKAdAvailabilityNo = 2
};


/*!
 *  @brief Enum for sdk error code.
 *  @since 2.0
 */
typedef NS_ENUM(NSUInteger, AFSDKErrorCode) {
    // General
    /** Unknown */
    AFSDKErrorCodeUnknown,
    /** Library isn't initialized yet */
    AFSDKErrorCodeLibraryNotInitialized,
    /** Internet isn't reachable (and is required) */
    AFSDKErrorCodeInternetNotReachable,
    /** You need to set the application delegate to proceed */
    AFSDKErrorCodeNeedsApplicationDelegate,
    
    // Initialization
    /** Missing the SDK Token */
    AFSDKErrorCodeInitializationMissingAPIKey,
    /** Missing the Secret Key */
    AFSDKErrorCodeInitializationMissingSecretKey,
    /** Missing the Features bitmask */
    AFSDKErrorCodeInitializationMissingFeatures,
    
    // Advertising sdk
    /** No ad available */
    AFSDKErrorCodeAdvertisingNoAd,
    /** The request call isn't appropriate */
    AFSDKErrorCodeAdvertisingBadCall,
    /** An ad is currently displayed for this format */
    AFSDKErrorCodeAdvertisingAlreadyDisplayed,
    /** The request was canceled by the developer */
    AFSDKErrorCodeAdvertisingCanceledByDevelopper,
    
    // Engage sdk
    /** The panel is already displayed */
    AFSDKErrorCodePanelAlreadyDisplayed,
    /** The notification wasn't found */
    AFSDKErrorCodeOpenNotificationNotFound,
    
    // In-app purchase
    /** The property object is not valid */
    AFSDKErrorCodeIAPPropertyNotValid,
    /** The property object is missing a title attribute */
    AFSDKErrorCodeIAPTitleMissing,
    /** The property object is missing a message attribute */
    AFSDKErrorCodeIAPMessageMissing,
    /** The property object is missing a cancel button title attribute */
    AFSDKErrorCodeIAPCancelButtonTitleMissing,
    /** The property object is missing a buy button title attribute */
    AFSDKErrorCodeIAPBuyButtonTitleMissing,
    /** The property object is missing a buy block handler */
    AFSDKErrorCodeIAPBuyBlockMissing,
};

/*!
 *  Enum to differentiate the device of a screenshot.
 *  @since 2.2
 */
typedef NS_ENUM(NSUInteger, AFAdSDKAppScreenshotType) {
    /** The screenshot type is unknown. */
    AFAdSDKAppScreenshotTypeUnknown = 0,
    /** iPhone screenshot type. */
    AFAdSDKAppScreenshotTypeiPhone,
    /** iPad screenshot type. */
    AFAdSDKAppScreenshotTypeiPad
};

/*!
 *  Enum to differentiate the orientation of a screenshot.
 *  @since 2.2
 */
typedef NS_ENUM(NSUInteger, AFAdSDKAppScreenshotOrientation) {
    /** The orientation of the screenshot is unknown. */
    AFAdSDKAppScreenshotOrientationUnknown = 0,
    /** The screenshot is in Portrait orientation. */
    AFAdSDKAppScreenshotOrientationPortrait,
    /** The screenshot is in Landscape orientation. */
    AFAdSDKAppScreenshotOrientationLandscape
};

/*!
 *  Enum about the kind of asset you can download in a sashimi.
 *  @since 2.4
 */
typedef NS_ENUM(NSUInteger, AFAdSDKAppAssetType) {
    /** The icon. */
    AFAdSDKAppAssetTypeIcon = 0,
    /** The screenshot. */
    AFAdSDKAppAssetTypeScreenshot
};
