//
//  YuMeTypes.h
//  YuMeiOSSDK
//
//  Created by Senthil on 11/21/14.
//  Copyright (c) 2014 YuMe. All rights reserved.
//

///////////////////////////////////////////////////////////////////////////////////////////
/*                                  YuMe SDK ENUMERATIONS                                */
///////////////////////////////////////////////////////////////////////////////////////////

/**
 * Enumerations specifying various YuMe ad block types available.
 */
typedef enum {
    
    /** Default Value. */
    YuMeAdTypeNone,
    
    /** Preroll slot ad. */
    YuMeAdTypePreroll,
    
    /** Midroll slot ad. */
    YuMeAdTypeMidroll,
    
    /** Postroll slot ad. */
    YuMeAdTypePostroll
    
} YuMeAdType;

/**
 * Enumerations specifying the ad events
 * that can be notified to the application from SDK.
 */
typedef enum {
    
    /** Default Value. */
    YuMeAdEventNone,
    
    /** SDK Initialization Successful. */
    YuMeAdEventInitSuccess,
    
    /** SDK Initialization Failed. */
    YuMeAdEventInitFailed,
    
    /**
     * Prefetch Cases:
     * 1. When a playlist is prefetched (when asset caching is disabled).
     * 2. When all the assets associated with a 100% prefetched playlist are downloaded (when asset caching is enabled).
     * 3. When the assets associated with the 1st valid ad in a >100% prefetched playlist are downloaded (when asset caching is enabled).
     * 4. When asset(s) caching for a prefetched playlist (with valid assets), cannot be completed due to reasons like storage space insufficient, storage space not accessible, etc., (when asset caching is enabled) – in this case the ad will be streamed when showAd() is called later.
     *
     * Streaming Cases:
     * 1. When a streaming ad (100% (or) >100%) is present and ready for playing.
     */
    YuMeAdEventAdReadyToPlay,
    
    /**
     * Prefetch Cases:
     * When a playlist is prefetched and
     * a) the playlist is empty (or)
     * b) no appropriate creative(s) present in the playlist.
     * Possible Ad Statuses that can be notified along with this e	vent:
     * YuMeAdStatusRequestFailed (or)
     * YuMeAdStatusRequestTimedOut (or)
     * YuMeAdStatusCachingFailed (or)
     * YuMeAdStatusCachedAdExpired (or)
     * YuMeAdStatusEmptyAdInCache
     *
     * Streaming Cases:
     * When a non-prefetched ad is requested and cannot be served.
     * Possible Ad Statuses that can be notified along with this event:
     * YuMeAdStatusRequestFailed (or)
     * YuMeAdStatusRequestTimedOut
     */
    YuMeAdEventAdNotReady,
    
    /** When a prefetched (or) streaming ad playback is started. */
    YuMeAdEventAdPlaying,
    
    /** Prefetch (or) Streaming Cases:
     * 1. When a prefetched (or) streaming ad playback is completed.
     * Possible Ad Statuses that can be notified along with this event:
     * YuMeAdStatusPlaybackSuccess (or)
     * YuMeAdStatusPlaybackTimedOut (or)
     * YuMeAdStatusPlaybackFailed (or)
     * YuMeAdStatusPlaybackInterrupted
     *
     * Streaming-specific Cases:
     * 1. Followed by an "YuMeAdEventAdNotReady" event.
     */
    YuMeAdEventAdCompleted,
    
    /** When an ad is clicked. */
    YuMeAdEventAdClicked,
    
    /** When an ad play is stopped on request from application and the SDK clean-up is completed. */
    YuMeAdEventAdStopped
    
} YuMeAdEvent;

/**
 * Enumerations specifying assets' download status.
 */
typedef enum {
    
    /** Default Value. */
    YuMeDownloadStatusNone,
    
    /** Assets downloads In Progress. */
    YuMeDownloadStatusDownloadsInProgress,
    
    /** Assets downloads Not In Progress. */
    YuMeDownloadStatusDownloadsNotInProgress,
    
    /** Assets downloads Paused. */
    YuMeDownloadStatusDownloadsPaused
    
} YuMeDownloadStatus;

/**
 * Enumerations specifying various play types that can be set by the application.
 */
typedef enum {
    
    /** Default Value. */
    YuMePlayTypeNone,
    
    /** Play type - Click to Play. */
    YuMePlayTypeClickToPlay,
    
    /** Play type - Auto Play. */
    YuMePlayTypeAutoPlay
    
} YuMePlayType;

/**
 * Enumerations specifying various error codes that SDK can send to the application.
 */
typedef enum {
    
    /** Default Value - No Error. */
    YuMeErrorNone,
    
    /** SDK is not initialized. */
    YuMeErrorNotInitialized,
    
    /** SDK is already initialized. */
    YuMeErrorAlreadyInitialized,
    
    /** Invalid Config Id. */
    YuMeErrorInvalidConfigId,
    
    /** Invalid handle. */
    YuMeErrorInvalidHandle,
    
    /** Invalid ad server url. */
    YuMeErrorInvalidURL,
    
    /** Invalid ad server domain. */
    YuMeErrorInvalidDomain,
    
    /** Invalid ad request timeout value. */
    YuMeErrorInvalidAdTimeout,
    
    /** Invalid video timeout (streaming) value. */
    YuMeErrorInvalidVideoTimeout,
    
    /** Invalid ad type. */
    YuMeErrorInvalidAdType,
    
    /** Ad request failed. */
    YuMeErrorAdRequestFailed,
    
    /** Ad Play failed. */
    YuMeErrorAdPlayFailed,
    
    /** Invalid Ad View. */
    YuMeErrorInvalidAdView,
    
    /** No Network Connection. */
    YuMeErrorNoNetworkConnection,
    
    /** Ad request already in progress. */
    YuMeErrorPreviousAdRequestInProgress,
    
    /** Ad play in progress. */
    YuMeErrorPreviousAdPlayInProgress,
    
    /** Invalid operation. */
    YuMeErrorInvalidOperation,
    
    /** Operation not allowed now. */
    YuMeErrorNotAllowedNow,
    
    /** Unknown Error. */
    YuMeErrorUnknown
    
} YuMeError;

/**
 * Enumerations specifying various events that can be notified from application/Player to SDK.
 */
typedef enum {
    
    /** Default Value. */
    YuMeEventTypeNone,
    
    /** The ad view has been resized by the application / Player.
     * The SDK will automatically detect the updated width and height of the ad View
     * using the Ad View handle that is passed with yumeSdkShowAd() */
    YuMeEventTypeAdViewResized
    
} YuMeEventType;

/**
 * Enumeration specifying various log levels.
 */
typedef enum {
    
    /** Log Level: None - disables logging. */
    YuMeLogLevelNone = 0,
    
    /** Log Level: Critical. */
    YuMeLogLevelCritical,
    
    /** Log Level: Error. */
    YuMeLogLevelError,
    
    /** Log Level: Warning. */
    YuMeLogLevelWarning,
    
    /** Log Level: Information. */
    YuMeLogLevelInfo,
    
    /** Log Level: Debug. */
    YuMeLogLevelDebug,
    
    /** Log Level: Verbose */
    YuMeLogLevelVerbose
    
} YuMeLogLevel;

/**
 * Enumeration specifying various Video Ad formats that can be played by YuMe Player.
 */
typedef enum {
    
    /** Video Ad Format: HLS. */
    YuMeVideoAdFormatHLS,
    
    /** Video Ad Format: MP4. */
    YuMeVideoAdFormatMP4,
    
    /** Video Ad Format: MOV. */
    YuMeVideoAdFormatMOV
    
} YuMeVideoAdFormat;

/**
 * Enumeration specifying different SDK usage modes.
 */
typedef enum {
    
    /** Default Value. */
    YuMeSdkUsageModeNone,
    
    /** SDK Usage Mode: Streaming */
    YuMeSdkUsageModeStreaming,
    
    /** SDK Usage Mode: Prefetch */
    YuMeSdkUsageModePrefetch
    
} YuMeSdkUsageMode;

/**
 * Enumerations specifying various Ad status.
 * These ad status will be notified to the application along with YuMeAdEvent.
 */
typedef enum {
    
    /** Default Value. */
    YuMeAdStatusNone,
    
    /**
     * Ad Status: Ad Request Failed.
     * Used with YuMeAdEventAdNotReady event.
     */
    YuMeAdStatusRequestFailed,
    
    /**
     * Ad Status: Ad Request Timed Out.
     * Used with YuMeAdEventAdNotReady event.
     */
    YuMeAdStatusRequestTimedOut,
    
    /**
     * Ad Status: Playback Successful.
     * Used with YuMeAdEventAdCompleted event.
     */
    YuMeAdStatusPlaybackSuccess,
    
    /**
     * Ad Status: Playback Timed Out.
     * Used with YuMeAdEventAdCompleted event.
     */
    YuMeAdStatusPlaybackTimedOut,
    
    /**
     * Ad Status: Playback Failed.
     * Used with YuMeAdEventAdCompleted event.
     */
    YuMeAdStatusPlaybackFailed,
    
    /**
     * Ad Status: Playback Interrupted due to "Call" (or) "Skip" overlay clicks.
     * Used with YuMeAdEventAdCompleted event.
     */
    YuMeAdStatusPlaybackInterrupted,
    
    /**
     * Ad Status: Prefetched Ad's Asset Caching Failed.
     * Used with YuMeAdEventAdNotReady event.
     */
    YuMeAdStatusCachingFailed,
    
    /**
     * Ad Status: Prefetched Ad Expired.
     * Used with YuMeAdEventAdNotReady event.
     */
    YuMeAdStatusCachedAdExpired,
    
    /**
     * Ad Status: Empty Prefetched Ad received (or) Empty ad already exists in Cache.
     * Used with YuMeAdEventAdNotReady event.
     */
    YuMeAdStatusEmptyAdInCache,
    
    /**
     * Ad Status: Assets' Caching of Prefetched Ad in Progress.
     * Used with YuMeAdEventAdNotReady event.
     */
    YuMeAdStatusCachingInProgress
    
} YuMeAdStatus;


///////////////////////////////////////////////////////////////////////////////////////////
/*                                  YuMe SDK DATA STRUCTURES                             */
///////////////////////////////////////////////////////////////////////////////////////////
/**
 * Container for the ad parameters that can be set by the application.
 */
@interface YuMeAdParams : NSObject {
}

/** Ad Server Url to be used for playlist requests.
 Default Value: nil. */
@property (nonatomic, strong) NSString *pAdServerUrl;

/** Ad Server Domain Identifier for playlist requests.
 Default Value: nil. */
@property (nonatomic, strong) NSString *pDomainId;

/** Optional. Additional QS Parameters to be added in the playlist request
 on behalf of the application.
 Default Value: nil. */
@property (nonatomic, strong) NSString *pAdditionalParams;

/** The playlist response timeout value (in seconds).
 Valid value is between 4 and 60 including.
 Default value is 5 (if timeOut < 4 default will be used).
 If timeOut is > 60 error will be returned. */
@property (nonatomic, assign) NSInteger adTimeout;

/** Timeout value for interruption during ad streaming (in seconds).
 Valid value is between 3 and 60 including.
 Default value is 6 (if value < 3, default will be used).
 If value is > 60 error will be returned. */
@property (nonatomic, assign) NSInteger videoTimeout;

/** Flag to indicate support for high bitrate mp4 ad videos.
 Default Value: YES. */
@property (nonatomic, assign) BOOL bSupportHighBitRate;

/** Flag to indicate if the SDK should automatically detect
 the current network and play the appropriate video based on the network identified.
 Default Value: NO. */
@property (nonatomic, assign) BOOL bSupportAutoNetworkDetect;

/** Flag to indicate if the control bar toggle should be enabled when displaying video ads.
 Default Value: YES. */
@property (nonatomic, assign) BOOL bEnableCBToggle;

/** The play type.
 Default Value: YuMePlayTypeNone. */
@property (nonatomic, assign) YuMePlayType ePlayType;

/** Flag to indicate if ad activity orientation set by the application
 can be overridden by the SDK during ad play (or) not. If YES, the SDK will reset the
 ad activity orientation back to its original value on ad completion.
 Default Value: YES. */
@property (nonatomic, assign) BOOL bOverrideOrientation;

/** Flag to enable tap to Calendar
 Default value: YES */
@property (nonatomic, assign) BOOL bEnableTTC;

/** The supported YuMe Video Ad Format types. The list elements will be of the type <YuMeVideoAdFormat>.
 Default value: nil. */
@property (nonatomic, strong) NSMutableArray *pVideoAdFormatsPriorityList;

/** The SDK Usage Mode (either PREFETCH (or) STREAMING mode).
 * The Publishers can change this setting either from server side (or) from application.
 * The mode switching can be done dynamically without having to deinit/init.
 * Default Value: YuMeSdkUsageModePrefetch.
 */
@property(nonatomic, assign) YuMeSdkUsageMode eSdkUsageMode;

/** The ad slot type supported by this SDK Instance.
 * The Publishers can change this setting either from server side (or) from application.
 * The mode switching can be done dynamically without having to deinit/init.
 * Default Value: YuMeAdTypePreroll.
 */
@property(nonatomic, assign) YuMeAdType eAdType;

/** Flag to indicate if playlist assets needs to be cached in case of prefetched playlists.
 Default Value: YES. */
@property (nonatomic, assign) BOOL bEnableCaching;

/** Flag to indicate if SDK can prefetch a playlist/assets automatically,
 after first prefetch is initiated by the application.
 Default Value: YES. */
@property (nonatomic, assign) BOOL bEnableAutoPrefetch;

/** Disk quota in MB for storing the prefetched assets.
 This should have a reasonable value for Ad pre-fetch to function properly.
 The minimum recommended value is 3 MB. If this value is <= 0 caching cannot be done, even if bEnableCaching is set to YES.
 Default Value: 0.0f. */
@property (nonatomic, assign) float storageSize;

/** Flag to indicate if the SDK needs to play the streaming ads automatically
 (or) not.
 If "YES", the ad will be played automatically when yumeSdkShowAd() is called.
 If NO, the ad will be fetched when yumeSdkInitAd() is called and
 it will be played when yumeSdkShowAd() is called.
 Default Value: YES. */
//@property (nonatomic, assign) BOOL bAutoPlayStreamingAds;

@end //@interface YuMeAdParams

/**
 * Container for getting the AdView information from the application.
 */
@interface YuMeAdViewInfo : NSObject {
}
/** Width of the Ad View. */
@property (nonatomic, assign) CGFloat width;

/** Height of the Ad View. */
@property (nonatomic, assign) CGFloat height;

/** X Coordinate of the Ad View. */
@property (nonatomic, assign) CGFloat left;

/** Y Coordinate of the Ad View. */
@property (nonatomic, assign) CGFloat top;

@end //@interface YuMeAdViewInfo
