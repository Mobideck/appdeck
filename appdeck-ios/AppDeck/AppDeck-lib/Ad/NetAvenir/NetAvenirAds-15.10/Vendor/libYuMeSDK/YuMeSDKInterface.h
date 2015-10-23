//
//  YuMeSDKInterface.h
//  YuMeiOSSDK
//
//  Created by Senthil on 11/21/14.
//  Copyright (c) 2014 YuMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YuMeTypes.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/*           INTERFACES TO BE IMPLEMENTED BY THE PUBLISHER APPLICATION FOR USE BY YUME SDK             */
/*   Please refer to YuMe iOS Integration Guide for use cases and workflow integration instructions.   */
/////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol YuMeAppDelegate <NSObject>

@required
/**
 * Listener that receives various ad events from YuMe SDK.
 * Used by the SDK to notify the application that the indicated ad event has occurred.
 * @param eAdType Ad type requested by the application that the event is related to.
 * @param eAdEvent The Ad event notified to the application.
 * @param eAdStatus The Ad status notified to the application.
 */
- (void)yumeEventListener:(YuMeAdType)eAdType adEvent:(YuMeAdEvent)eAdEvent adStatus:(YuMeAdStatus)eAdStatus;

/**
 * Gets the AdView Info.
 * Used by the SDK to get the AdView Info from the application.
 * @return The AdView Info object.
 */
- (YuMeAdViewInfo *)yumeGetAdViewInfo;

/**
 * Gets the updated QS parameters.
 * Used by SDK to get the recently updated qs params from the application.
 * For eg: App can send the latest lat and lon through this method for use by SDK.
 * @return The set of key value pairs delimited by '&'.
 */
- (NSString *)yumeGetUpdatedQSParams;

@end //@protocol YuMeAppDelegate


/////////////////////////////////////////////////////////////////////////////////////////////////////////
/*            API INTERFACES IMPLEMENTED BY THE YUME SDK FOR USE BY PUBLISHER APPLICATION              */
/*   Please refer to YuMe iOS Integration Guide for use cases and workflow integration instructions.   */
/////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface YuMeSDKInterface : NSObject

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//                    API INTERFACES COMMON FOR BOTH STREAMING AND PREFETCH MODES                      //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Gets the YuMe SDK Handle.
 * @return The YuMe SDK handle or nil if an error occurs..
 */
+ (YuMeSDKInterface *)getYuMeSdkHandle;

/**
 * Gets the YuMe SDK Version.
 * @return The YuMe SDK version.
 */
+ (NSString *)getYuMeSdkVersion;

/**
 * Initializes the YuMe SDK with ad params and app interface handle.
 * This API needs to be used by Publishers who needs to utilize YuMe Player for playing video and non-video ad components.
 * @param pAdParams The Ad Param object prefilled with the values to be initialized. This will be used if the SDK is unable to fetch config data from server.
 * The attributes pAdServerUrl, pDomainId are mandatory. The attribute storageSize must be > 0 for Ad pre-fetch to work.
 * @param pAppDelegate Handle of an object that implements YuMeAppDelegate protocol.
 * @param ppError A double pointer to an NSError object where a newly created error object will be returned in case an error occurs.
 * @return YES, if operation is successful, else NO.
 * NOTE 1: The Application SHOULD NOT consider that SDK Initialization is successful based on the return value of this API. Instead, it should wait for
 * "YuMeAdEventInitSuccess" event from YuMe SDK.
 * NOTE 2: If SDK is Initialized in Prefetch Mode, it will make the first Prefetch Ad request automatically soon after Initialization, thus eliminating the
 * need for Publisher application calling yumeSdkInitAd().
 */
- (BOOL)yumeSdkInit:(YuMeAdParams *)pAdParams appDelegate:(id<YuMeAppDelegate>)pAppDelegate errorInfo:(NSError **)ppError;

/**
 * De-initializes the YuMe SDK.
 * @param ppError A double pointer to an NSError object where a newly created error object will be returned in case an error occurs.
 * @return YES, if operation is successful, else NO.
 */
- (BOOL)yumeSdkDeInit:(NSError **)ppError;

/**
 * Modifies the Ad Parameters set in YuMe SDK.
 * @param pAdParams The Ad Param object prefilled with the values to be modified.
 * The attributes pAdServerUrl, pDomainId are mandatory. The attribute storageSize must be > 0 for Ad pre-fetch to work.
 * @param ppError A double pointer to an NSError object where a newly created error object will be returned in case an error occurs.
 * @return YES, if operation is successful, else NO.
 */
- (BOOL)yumeSdkModifyAdParams:(YuMeAdParams *)pAdParams errorInfo:(NSError **)ppError;

/**
 * Gets the Ad Parameters set in YuMe SDK.
 * @param ppError A double pointer to an NSError object where a newly created error object will be returned in case an error occurs.
 * @return The ad param object if present, else nil.
 */
- (YuMeAdParams *)yumeSdkGetAdParams:(NSError **)ppError;

/**
 * Plays an ad.
 * NOTE 1: If SDK is Initialized in Streaming mode, it fetches an ad before playing.
 * NOTE 2: If SDK is Initialized in Prefetch mode, it plays an ad, if a prefetched ad is reqdily available for playing, else,
 * returns NO with appropriate error message.
 * @param pAdView The UIView inside which the Ad will be played.
 * @param pAdViewController The UIViewController inside which the Ad will be played.
 * @param ppError A double pointer to an NSError object where a newly created error object will be returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkShowAd:(UIView *)pAdView viewController:(UIViewController *)pAdViewController errorInfo:(NSError **)ppError;

/**
 * Stops the playback of currently playing ad.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 * NOTE: The Application SHOULD NOT clean-up the ad related UI Views / View Controllers, immediately after calling this API.
 * Instead, it should wait for "YuMeAdEventAdStopped" event from YuMe SDK and then proceed with the necessary clean-up.
 */
- (BOOL)yumeSdkStopAd:(NSError **)ppError;

/**
 * Clears the cookies created by YuMe SDK.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkClearCookies:(NSError **)ppError;

/**
 * Enables / disables Control Bar toggle for next gen ads.
 * If disabled, control bar will be displayed through out for video (or) image slates.
 * Else, will be shown for 'x' seconds and then hidden after that, until the user taps the video / image again.
 * @param bEnableCBToggle Flag indicating if control bar toggling should be enabled or not.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkSetControlBarToggle:(BOOL)bEnableCBToggle errorInfo:(NSError **)ppError;

/**
 * Handles the specified event that occurred in the application.
 * @param eEventType The enum value representing the app event that occurred.
 * NOTE: If eEventType is 'YuMeEventTypeAdViewResized', the application should ensure that
 * the Ad View is resized before calling this API.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkHandleEvent:(YuMeEventType)eEventType errorInfo:(NSError **)ppError;

/**
 * Sets the log level in the YuMe SDK.
 * @param logLevel Enum representing the log level required.
 */
- (void)yumeSdkSetLogLevel:(YuMeLogLevel)logLevel;

/**
 * Checks whether an Ad is available for playing.
 * It is highly recommended to use this API before any calls to yumeSdkShowAd().
 * The purpose of this API is provide more insight into the Application running scenarios and Ad availability at any point of time.
 * @param ppError A double pointer to an NSError object where a newly created error object will be returned in case an error occurs.
 * @return: YES, if there is an Ad, else NO.
 * NOTE: If SDK is Initialized in Streaming mode, this API will always return YES.
 */
- (BOOL)yumeSdkIsAdAvailable:(NSError **)ppError;


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//                             API INTERFACES SPECIFIC FOR PREFETCH MODE                               //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Prefetches a preroll, midroll (or) postroll ad as configured & also caches all the assets required (PREFETCH MODE) (OR)
 * The API yumeSdkShowAd(), should be called in order to play the Ad.
 * If caching is enabled, then ad creatives will also be downloaded.
 * NOTE: It will take some time (based upon the network speed) for downloading the ad creatives.
 * If yumeSdkShowAd() is called before download is completed, Ad won't be displayed.
 * Calling yumeSdkInitAd() more than once with the same set of parameters
 * (like adServerUrl, domainId, additional params, etc) has no effect.
 * But if any of the additional parameter changes, a new Ad request will be made.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkInitAd:(NSError **)ppError;

/**
 * Enables / disables caching support.
 * If disabled, assets will NOT be cached.
 * This setting has no effect on prefetching a playlist.
 * @param bEnableCache Flag indicating if caching support should be enabled or not.
 * If YES, when yumeSdkInitAd() is called all required ad assets will be cached locally.
 * If NO, when yumeSdkInitAd() is called only playlist will be cached. Assets will
 * be streamed when yumeSdkShowAd() is called.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkSetCacheEnabled:(BOOL)bEnableCache errorInfo:(NSError **)ppError;

/**
 * Checks whether asset caching is enabled (or) not.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if caching is enabled, else NO.
 * NOTE: In case of errors, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkIsCacheEnabled:(NSError **)ppError;

/**
 * Enables/Disables Auto prefetch mode.
 * If enabled, a new Ad will be prefetched automatically after Ad play is complete (or) stopped.
 * @param bAutoPrefetch Flag indicating if auto-prefetch should be enabled or not.
 * If YES, when the Ad play (initiated by yumeSdkShowAd()) is completed,
 * another Ad WILL be fetched automatically.
 * If NO, when the Ad play (initiated by yumeSdkShowAd()) is completed,
 * another Ad WILL NOT be fetched automatically.
 * If auto prefetch is disabled, application should call yumeSdkInitAd() every time
 * an ad needs to be pre-fetched, after the first ad play attempt.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkSetAutoPrefetch:(BOOL)bAutoPrefetch errorInfo:(NSError **)ppError;

/**
 * Checks whether auto prefetch is enabled (or) not.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if auto prefetch is enabled, else, NO.
 * NOTE: In case of errors, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkIsAutoPrefetchEnabled:(NSError **)ppError;

/**
 * Clears the asset cache.
 * It will clear all the playlists and creatives that were cached already.
 * If no ad is downloading and auto prefetch is enabled and a prefetch operation was attempted before,
 * a new ad request will be made immediately after clearing the assets' cache.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkClearCache:(NSError **)ppError;

/**
 * Pauses the currently active downloads.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkPauseDownload:(NSError **)ppError;

/**
 * Resumes the paused downloads.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkResumeDownload:(NSError **)ppError;

/**
 * Aborts the currently active/paused downloads.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return YES, if operation is successful, else NO. If NO is returned, the ppError object will contain appropriate error info.
 */
- (BOOL)yumeSdkAbortDownload:(NSError **)ppError;

/**
 * Gets the current download status.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return The current download status.
 * NOTE: In case of errors, the ppError object will contain appropriate error info.
 */
- (YuMeDownloadStatus)yumeSdkGetDownloadStatus:(NSError **)ppError;

/**
 * Gets the download percentage completed so far, for the currently active Ad.
 * @param ppError A double pointer to an NSError object where a newly created error object will returned in case an error occurs.
 * @return The percentage downloaded so far, for the active Ad. If no Ad is active, 0.0f will be returned.
 * NOTE: In case of errors, the ppError object will contain appropriate error info.
 */
- (float)yumeSdkGetDownloadedPercentage:(NSError **)ppError;

@end //@interface YuMeSDKInterface
