/*!
 *  @header    AppsfireSDKConstants.h
 *  @abstract  Appsfire SDK Constants Header
 *  @version   2.3.1
 */

/*!
 *  @brief Names of notifications you can observe in Appsfire SDK
 *  @since 2.0
 */

/** sdk is initializing */
#define kAFSDKIsInitializing                @"AFSDKisInitializing"

/** sdk is initialized */
#define kAFSDKIsInitialized                 @"AFSDKisInitialized"

/** notifications count was updated */
#define kAFSDKNotificationsNumberChanged    @"AFSDKNotificationsNumberChanged"

/** dictionary (localized strings) is updated */
#define kAFSDKDictionaryUpdated             @"AFSDKdictionaryUpdated"

/** panel (for notifications or feedback) was presented */
#define kAFSDKPanelWasPresented             @"AFSDKPanelWasPresented"

/** panel (for notifications or feedback) was dismissed */
#define kAFSDKPanelWasDismissed             @"AFSDKPanelWasDismissed"


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
    AFSDKFeatureMonetization    = 1 << 1,
    /** Track feature */
    AFSDKFeatureTrack           = 1 << 2
};


/*!
 *  @brief Enum for deciding appsfire sdk presentation style.
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
 *  @brief Enum for deciding appsfire sdk content type.
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
 *  @brief Enum for specifying the modal type.
 *  @since 2.1
 */
typedef NS_ENUM(NSUInteger, AFAdSDKModalType) {
    /** A native fullscreen ad */
    AFAdSDKModalTypeSushi = 0,
    /** An interstitial, with experience similar to the task manager in iOS7, except it happens within the publisher app */
    AFAdSDKModalTypeUraMaki = 1
};


/*!
 *  @brief Enum for specifying the sashimi format.
 *  @since 2.2
 */
typedef NS_ENUM(NSUInteger, AFAdSDKSashimiFormat) {
    /**  */
    AFAdSDKSashimiFormatMinimal = 0,
    /**  */
    AFAdSDKSashimiFormatExtended = 1
};


/*!
 *  @brief Enum for specifying the ad availability.
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
    AFSDKErrorCodeOpenNotificationNotFound
    
};
