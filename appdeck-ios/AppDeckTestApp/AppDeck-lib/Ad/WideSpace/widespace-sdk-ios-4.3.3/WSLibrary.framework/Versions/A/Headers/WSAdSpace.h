//
//  WSAdSpace.h
//  Widespace-SDK-iOS
//  Version: 4.3.3-bb55acc
//  Copyright (c) 2012 Widespace . All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *   NS_ENUM is available from iOS 6.0. So it needs to define NS_ENUM if it is not defined.
 */
#ifndef NS_ENUM
  #define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

/**
 *   Specifies the status for media files when prefetching an ad.
 *   @available since 4.1
 */
typedef NS_ENUM(NSUInteger, WSMediaStatus)
{
	/**
	 *   The prefetched ad has no media files.
	 */
	WSMediaStatusNoMedia,

	/**
	 *   The prefetched ad has one or more media files that have been cached.
	 */
	WSMediaStatusMediaCached,

	/**
	 *   The prefetched ad has one or more media files that have not been cached.
	 */
	WSMediaStatusMediaNotCached
};

/**
 *   Specifies the type of media file.
 *   @available since 4.1
 */
typedef NS_ENUM(NSUInteger, WSMediaType)
{
	/**
	 *   Specifies a media type that it is audio.
	 */
	WSMediaTypeAudio,

	/**
	 *   Specifies a media type that it is video.
	 */
	WSMediaTypeVideo
};

/**
 *   Specifies the error type for an error published by the didFailWithError: method.
 *   @available since 4.1
 *   @see didFailWithError:
 */
typedef NS_ENUM(NSUInteger, WSErrorType)
{
	/**
	 *   The error was caused by a network problem.
	 */
	WSErrorTypeNetworkError,

	/**
	 *   The error was caused by an invalid .ics calendar file.
	 */
	WSErrorTypeICSParseError,

	/**
	 *   Media file download failed due to a network error.
	 */
	WSErrorTypeMediaDownloadInterruption,

	/**
	 *   The error was caused by a missing media file.
	 */
	WSErrorTypeMediaNotFound,

	/**
	 *   The ad server responded with an error.
	 */
	WSErrorTypeInvalidSID,

	/**
	 *   The error was caused due to a permission failure when the SDK tried to save an image to the photo album.
	 */
	WSErrorTypePermission,

	/**
	 *   The error was caused by an invalid layout.
	 */
	WSErrorTypeLayoutError,

	/**
	 *   The error was caused by using a deprecated feature of the SDK.
	 */
	WSErrorTypeDeprecatedSDK,

	/**
	 *   The error was caused by calling runAd: too often.
	 */
	WSErrorTypeConnectionLimit,

	/**
	 *   The error was caused due to a failure or problem with an ad.
	 */
	WSErrorTypeHTTPError,

	/**
	 *   The error was caused by invalid ad JSON data.
	 */
	WSErrorTypeJSONParseError,

	/**
	 *   The error was caused due to calling prefetchAd when the prefetch queue size limit is reached.
	 */
	WSErrorTypeAdQueueFull,

	/**
	 *   The error was caused by receiving "No Ad" response from the ad server.
	 */
	WSErrorTypeNoAd,

	/**
	 *   The error was caused by an unknown error.
	 */
	WSErrorTypeUnknown
};

/**
 *   Specifies the animation direction for an expand or collapse operation.
 *   @available since 4.1
 */
typedef NS_ENUM(NSUInteger, WSAnimationDirection)
{
	/**
	 *   The animation direction is considered to be upwards in relation to the WSAdSpace position.
	 */
	WSAnimationDirectionUp,

	/**
	 *   The animation direction is considered to be downwards in relation to the WSAdSpace position.
	 */
	WSAnimationDirectionDown,

	/**
	 *   The WSAdSpace will open a modal view in full screen.
	 */
	WSAnimationDirectionFullScreen
};

/**
 *   Specifies the ad type.
 *   @available since 4.1
 */
typedef NS_ENUM(NSUInteger, WSAdType)
{
	/**
	 *   The ad type is a "normal" ad.
	 */
	WSAdTypeNormal,

	/**
	 *   The ad type is an "expandable" ad.
	 */
	WSAdTypeExpandable,

	/**
	 *   The ad type is a "raw" ad.
	 */
	WSAdTypeRaw,

	/**
	 *   The ad type is a "splash" ad.
	 */
	WSAdTypeSplash
};

@protocol WSAdSpaceDelegate;

/**
 *   An instance of WSAdSpace is a means for displaying ads in your app.
 *
 *   The AdSpace manages ads and presents them based on your input and configuration. Ads will be retrieved from the Widespace ad network and targeted to your users demography data for the best experience possible.
 */
@interface WSAdSpace : UIView
{
	id <WSAdSpaceDelegate> delegate;
}

/**
 *   The delegate of the AdSpace that you want to receive messages of what is happening. Not required.
 *   @see WSAdSpaceDelegate
 */
@property (nonatomic, assign) id <WSAdSpaceDelegate> delegate;

/**
 *   Determines if the WSAdSpace is using the GPS to target ads towards the end user. Setting this to NO will set it to NO for all WSAdSpaces during this session. Setting it to YES will turn location on for all WSAdSpaces.
 *   <p>
 *   Default value is YES. This can also be set in initWithFrame:sid:autoUpdate:autoStart:delegate:GPSEnabled:
 *   </p>
 */
@property (nonatomic, assign, getter = isGPSEnabled, setter = setGPSEnabled :) BOOL gpsEnabled;

/**
 *   Set to pause or resume the AdSpace.
 *   @see pause
 *   @see resume
 */
@property (nonatomic, assign, getter = isPaused) BOOL paused;

/**
 *   The SID of AdSpace was initialized with, you can set this to a different SID to load new ads (changing this property will clear the AdQueue)
 *   This needs to be set to a proper SID obtained from Widespace. Without a valid SID you will not get any ads.
 */
@property (nonatomic, retain) NSString *sid;

/**
 *   Decide if the AdSpace should draw a drop shadow under the ads.
 */
@property (nonatomic, assign, getter = isShadowEnabled) BOOL shadowEnabled;

/**
 *   Controls how much user related information is sent with each request. If your app is going to be published in a market with strict privacy laws (ex. Germany), you should most likely enable this. Calling this method will also clear the internal queue of ads (ex. if you have used prefetch, you will have to use prefetch again to get new ads). Setting regulated mode will clear the ad queue.
 */
@property (nonatomic, assign, getter = isRegulatedMode) BOOL regulatedMode;

/**
 *   Get all extra paramters as a dictionary.
 *   @see setExtraParameter:value:
 */
@property (nonatomic, readonly) NSDictionary *extraParamters;

/**
 *   Decide if AdSpace should fetch new ads and present them automatically (assuming AdSpace is running). This is also set in the init method.
 */
@property (nonatomic, assign, getter = isAutoUpdate) BOOL autoUpdate;

/**
 *   Get the current ad description. This holds ad id, layout parameters and update time among other things.
 *   This is a direct representation of the JSON response.
 *   @see nextAdInfo
 */
@property (nonatomic, readonly) NSDictionary *currentAdInfo;

/**
 *   Get the next ad description. This holds ad id, layout parameters and update timer among other things.
 *   This is a direct representation of the JSON response.
 *   @see currentAdInfo
 */
@property (nonatomic, readonly) NSDictionary *nextAdInfo;

/**
 *   Returns an AdSpace that presents ads and should be added to the screen.
 *   <p>
 *   The SID must be set to a valid SID that you have obtained from Widespace (Nova Front).
 *   This instance will auto update and auto run. Default frame is here (0, 0, 320, 48), delegate is nil and GPS is enabled.
 *   </p>
 *
 *   @param sid SID for the adspace.
 *
 *   @return The WSAdSpace instance with settings provided in initializer.
 */
- (id)initWithSid:(NSString *)sid;

/**
 *   Returns an AdSpace that presents ads and should be added to the screen.
 *   GPS is enabled here by default.
 *
 *   @param frame Frame of the adspace, used for sizing the incoming ads and deciding where to place them on screen.
 *   @param sid SID for the adspace.
 *   @param autoUpdate AdSpace will continue fetching and presenting ads automatically (assuming the AdSpace is autoStart:YES or has fired -runAd).
 *   @param autoStart AdSpace will fetch and present an ad immediately.
 *   @param adSpaceDelegate The delegate of the AdSpace that you want to receive messages of what is happening. (Optional)
 *
 *   @return The WSAdSpace instance with settings provided in initializer.
 *
 *   @warning Deprecated since 4.1 due to changed order of arguments, use initWithFrame:sid:autoStart:autoUpdate:delegate instead
 */
- (id)initWithFrame:(CGRect)frame sid:(NSString *)sid autoUpdate:(BOOL)autoUpdate autoStart:(BOOL)autoStart delegate:(id <WSAdSpaceDelegate>)adSpaceDelegate DEPRECATED_ATTRIBUTE;

/**
 *   Returns an AdSpace that presents ads and should be added to the screen.
 *   GPS is enabled here by default.
 *   <p>
 *   The frame must be set to the intended size of the Ads to display on the screen, if you specify a frame that is too small you will get an error in the delegate method -didFailWithError. Typical size of frame for an iPhone app that receives Panorama and Expandable ads is CGRect(0, 0, 320, 48).
 *
 *   The SID must be set to a valid SID that you have obtained from Widespace (Nova Front).
 *
 *   If you set autoUpdate to YES the AdSpace will fetch and present updates automatically. If you set autoUpdate to NO you will manually have to tell the adSpace to run to fetch the next ad and present it (you may also prefetch manually to have the next ad cached before running to be able to present the ad at an exact time without delay).
 *
 *   With autoStart set to YES the AdSpace will fetch an ad and present it as soon as it is initialized.
 *   </p>
 *
 *   @param frame Frame of the adspace, used for sizing the incoming ads and deciding where to place them on screen.
 *   @param sid SID for the adspace.
 *   @param autoStart AdSpace will fetch and present an ad immediately.
 *   @param autoUpdate AdSpace will continue fetching and presenting ads automatically (assuming the AdSpace is autoStart:YES or has fired -runAd).
 *   @param adSpaceDelegate The delegate of the AdSpace that you want to receive messages of what is happening. (Optional)
 *
 *   @return The WSAdSpace instance with settings provided in initializer.
 */
- (id)initWithFrame:(CGRect)frame sid:(NSString *)sid autoStart:(BOOL)autoStart autoUpdate:(BOOL)autoUpdate delegate:(id <WSAdSpaceDelegate>)adSpaceDelegate;

/**
 *   Additional initializer method for setting if the WSAdSpace should gather GPS location.
 *   @see initWithFrame:sid:autoStart:autoUpdate:delegate
 *
 *   @param frame Frame of the adspace, used for sizing the incoming ads and deciding where to place them on screen.
 *   @param sid SID for the adspace.
 *   @param autoStart AdSpace will fetch and present an ad immediately.
 *   @param autoUpdate AdSpace will continue fetching and presenting ads automatically (assuming the AdSpace is autoStart:YES or has fired -runAd).
 *   @param adSpaceDelegate The delegate of the AdSpace that you want to receive messages of what is happening. (Optional)
 *   @param gpsEnabled Determines if all WSAdSpace instances should use GPS location, this will be over ridden if you initialize with initWithFrame:sid:autoUpdate:autoStart:delegate since it defaults to YES.
 *
 *   @return The WSAdSpace instance with settings provided in initializer.
 */
- (id)initWithFrame:(CGRect)frame sid:(NSString *)sid autoStart:(BOOL)autoStart autoUpdate:(BOOL)autoUpdate delegate:(id <WSAdSpaceDelegate>)adSpaceDelegate GPSEnabled:(BOOL)gpsEnabled;

/**
 *   Prefetch the next ad so you have it ready for presenting without delay, you will have to wait for prefetching to be done. When prefetching is done you will receive a callback to your delegate that informs you that the AdSpace is ready to run the ad. This method returns immediately. When prefetching, the fetched ad will be placed in the ad queue where it is available for you to run.
 *   @see WSAdSpaceDelegate
 *   @see runAd
 */

- (void)prefetchAd;

/**
 *   Present the next ad in the ad queue, if isAutoRun:YES the AdSpace will continue fetching and running ads after the first ad is finished. If the ad queue is empty the AdSpace will first fetch an ad, place it in the ad queue and then run the first item in the ad queue.
 */
- (void)runAd;

/**
 *   Close the current ad show by the AdSpace.
 *   This will stop any video or audio the ad is playing and animate out.
 */
- (void)closeAd;

/**
 *   Pause the AdSpace. After this method is called, no ads will be automatically fetched or displayed until resume is called. This also pauses any video or audio the current ad is playing.
 *   @see resume
 */
- (void)pause;

/**
 *   Resumes previously paused AdSpace. After this method is called, it will continue its display timer and close it self when it is done. This will also resume any video or audio the current ad is playing.
 *   @see pause
 */
- (void)resume;

/**
 *   Run before destroying AdSpace to free resources.
 *
 *   @warning Deprecated since 4.1
 */
- (void)stop;

/**
 *   Check if the AdSpace is paused or not.
 *   @return YES if AdSpace is paused.
 *
 *   @warning Deprecated since 4.1 due to property replacement, please use paused instead.
 */
- (BOOL)isPaused;

/**
 *   Set the SID for the AdSpace, this will clear the current ad queue and begin fetching ads again if isAutoUpdate:YES. This is also set in the init method. Changing SID will clear the ad queue.
 *   @param sid SID to set for the AdSpace.
 *   @see initWithFrame:sid:autoUpdate:autoStart:delegate
 *
 *   @warning Deprecated since 4.1 due to property replacement, please use sid instead.
 */

- (void)setSid:(NSString *)sid DEPRECATED_ATTRIBUTE;

/**
 *   Get the SID for the AdSpace.
 *   @return The current sid for the AdSpace.
 *
 *   @warning Deprecated since 4.1 due to property replacement, please use sid instead.
 */
- (NSString *)getSid DEPRECATED_ATTRIBUTE;

/**
 *   Convenience method for setting just the position of the AdSpace instead of setting the whole frame.
 *   @param point The position you want the AdSpace to be positioned at.
 *   @warning Deprecated since 4.1 - Should use frame property of WSAdSpace instead.
 */
- (void)setAdSpacePosition:(CGPoint)point DEPRECATED_ATTRIBUTE;

/**
 *   Convenience method for setting the frame of the AdSpace.
 *   @param frame The frame you want the AdSpace to have.
 *   @warning Deprecated since 4.1 - Should use frame property of WSAdSpace instead.
 */
- (void)setAdSpaceFrame:(CGRect)frame DEPRECATED_ATTRIBUTE;

/**
 *   Decide if the AdSpace should animate the ads when presenting or dismissing them.
 *   @param animation If YES, the AdSpace will animate the ads.
 *
 *   @warning Deprecated since 4.1
 */
- (void)setAnimation:(BOOL)animation DEPRECATED_ATTRIBUTE;

/**
 *   Decide if the AdSpace should draw a drop shadow under the ads.
 *   @param shadow If YES shadow will be applied to ads.
 *
 *   @warning Deprecated since 4.1 due to property replacement, please use shadowEnabled instead.
 */
- (void)setShadow:(BOOL)shadow DEPRECATED_ATTRIBUTE;

/**
 *   Controls how much user related information is sent with each request. If your app is going to be published in a market with strict privacy laws (ex. Germany), you should most likely enable this. Calling this method will also clear the internal queue of ads (ex. if you have used prefetch, you will have to use prefetch again to get new ads). Setting regulated mode will clear the ad queue.
 *   @param regulatedMode If YES regulated mode is active.
 *
 *   @warning Deprecated since 4.1 due to property replacement, please use regulatedMode instead.
 */
- (void)setRegulatedMode:(BOOL)regulatedMode DEPRECATED_ATTRIBUTE;

/**
 *   Pass extra parameters to the query string against engine.
 *   @param keyValue Dictionary that replaces all current extra parameters.
 *
 *   @warning Deprecated since 4.1 due to single key value setter implementation that just adds to the existing extra properties. The new method also validates input so the request does not break.
 */
- (void)setExtraParameters:(NSDictionary *)keyValue DEPRECATED_ATTRIBUTE;

/**
 *   Pass extra parameters to the query string against engine. Extra parameters will be added to the extra parameters list, to remove an extra parameter pass the desired key with value = nil.
 *   <p>
 *   You should add demography data here if you have it gathered. Doing this will help direct more targeted ads for the current user which in turn gives you a higher revenue.
 *
 *   Example Keys and Values:
 *
 *   @"postal"  : @"12345"      =   Users postal code. <br>
 *   @"city"    : @"Stockholm"  =   Users city of residence. <br>
 *   @"age"     : @"25"         =   Users age in years. 0-99. <br>
 *   @"yob"     : @"1980"       =   Users birthyear, full 4 digit format. 1900-2013. <br>
 *   @"sex"     : @"1"          =   Users sex. 1 = male | 2 = female
 *   </p>
 *   @param key The key for the value when requesting data from engine.
 *   @param value The value for the key when requesting data from engine.
 *
 *   @return YES if parameter key and value is allowed and was set.
 *
 */
- (BOOL)setExtraParameter:(NSString *)key value:(NSString *)value;

/**
 *   Returns whether this AdSpace is auto updating or not.
 *   @return YES if AdSpace is auto updating.
 *
 *   @warning Deprecated since 4.1 due to property replacement, please use autoUpdate instead.
 */
- (BOOL)isAutoUpdating DEPRECATED_ATTRIBUTE;

/**
 *   Decide if AdSpace should fetch new ads and present them accordingly. This is also set in the init method.
 *   @param autoUpdate AdSpace will continue fetching and presenting ads automatically (assuming the AdSpace is autoStart:YES or has fired -runAd).
 *   @see initWithFrame:sid:autoUpdate:autoStart:delegate:
 *
 *   @warning Deprecated since 4.1 due to property replacement, please use autoUpdate instead.
 */
- (void)setAutoUpdate:(BOOL)autoUpdate DEPRECATED_ATTRIBUTE;

/**
 *   Clear the ad queue, this will leave you with no ads in the queue so if you want to place a new ad in the ad queue you have to call prefetchAd.
 *   @warning Deprecated since 4.1 (not needed by publishers)
 */
- (void)clearQueue DEPRECATED_ATTRIBUTE;

/**
 *   Specify the size of the ad queue.
 *   <p>
 *   By default the queue size is 2. The value can be between 2 and 10. Setting a value that is not valid will return NO.
 *   </p>
 *   @param size The numer of ads you want to be able to cache in the ad queue.
 *   @see getQueueSize
 *   @return YES if size is allowed
 */
- (BOOL)setQueueSize:(int)size;

/**
 *   Read the queue size if the AdSpace
 *   @see setQueueSize:
 */
- (int)getQueueSize;

/**
 *   Get the current ad description. This holds ad id, layout parameters and update timer among other things.
 *   @return The current ad description as parsed from the JSON response.
 *   @see getNextAdDescription
 *
 *   @warning Deprecated since 4.1 due to property replacement, please use currentAdInfo instead.
 */
- (NSMutableDictionary *)getCurrentAdDescription DEPRECATED_ATTRIBUTE;

/**
 *   Get the next ad description. This holds ad id, layout parameters and update timer among other things.
 *   @return The next ad description as parsed from the JSON response.
 *   @see getCurrentAdDescription
 *
 *   @warning Deprecated since 4.1 due to property replacement, please use nextAdInfo instead.
 */
- (NSMutableDictionary *)getNextAdDescription DEPRECATED_ATTRIBUTE;

/**
 *   Get the estimated size of the next ad.
 *   @return Size in pixels.
 *
 *   @warning Deprecated since 4.1
 */
- (CGSize)nextAdEstimatedSize DEPRECATED_ATTRIBUTE;

@end

/**
 *   The delegate of a WSAdSpace object must adopt the WSAdSpaceDelegate protocol. Optional methods of the protocol allow the delegate to receive notifications about what is happening with the ads and the WSAdSpace.
 *   <p>
 *   All the methods of the WSAdSpaceDelegate protocol are optional.
 *   </p>
 */
@protocol WSAdSpaceDelegate <NSObject>

@optional

/**
 *   Provide a specific UIViewController to the WSAdSpace for fetching interface orientation and calculating available screen space. Will be handled automatically if not implemented.
 */
- (UIViewController *)wsParentViewController;

/**
 *   AdSpace will close the current ad.
 *   @param adSpace The AdSpace that is closing the ad.
 *   @param adType Enum describing the type of ad that is being closed.
 */
- (void)willCloseAd:(WSAdSpace *)adSpace withAdType:(WSAdType)adType;

/**
 *   AdSpace will close the current ad.
 *   @param adSpace The AdSpace that is closing the ad.
 *   @param adType String describing the type of ad that is being closed.
 *   @warning Deprecated since 4.1 due to replacement method.
 */
- (void)willCloseAd:(WSAdSpace *)adSpace adType:(NSString *)adType DEPRECATED_ATTRIBUTE;

/**
 *   AdSpace closed the current ad.
 *   @param adSpace The AdSpace that closed the ad.
 *   @param adType Enum describing the type of ad that was closed.
 */
- (void)didCloseAd:(WSAdSpace *)adSpace withAdType:(WSAdType)adType;

/**
 *   AdSpace closed the current ad.
 *   @param adSpace The AdSpace that closed the ad.
 *   @param adType String describing the type of ad that was closed.
 *   @warning Deprecated since 4.1 due to replacement method.
 */
- (void)didCloseAd:(WSAdSpace *)adSpace adType:(NSString *)adType DEPRECATED_ATTRIBUTE;

/**
 *   AdSpace will request for a new ad. This callback fires just before sending a request for a new ad.
 *   @param adSpace The AdSpace that will request an ad.
 */
- (void)willLoadAd:(WSAdSpace *)adSpace;

/**
 *   AdSpace just successfully received an ad information. This callback fires when AdSpace successfully received an ad information.
 *   @param adSpace The AdSpace that received the ad.
 *   @param adType Enum describing the type of ad that was received.
 */
- (void)didLoadAd:(WSAdSpace *)adSpace withAdType:(WSAdType)adType;

/**
 *   AdSpace just successfully received an ad information. This callback fires when AdSpace successfully received an ad information.
 *   @param adSpace The AdSpace that received the ad.
 *   @param adType String describing the type of ad that was received.
 *   @warning Deprecated since 4.1 due to replacement method.
 */
- (void)didLoadAd:(WSAdSpace *)adSpace adType:(NSString *)adType DEPRECATED_ATTRIBUTE;

/**
 *   AdSpace will start playing a movie or a sound, you should react to this if you are playing audio or video in your app.
 *   <p>
 *   Example usage: You should make sure your users do not have a bad user experience where they hear two sounds at the same time while the ad is playing its media.
 *   </p>
 *   @param adSpace The AdSpace that has the ad with the media that will start to play.
 *   @param mediaType Enum describing the media type being started.
 */
- (void)willStartMedia:(WSAdSpace *)adSpace withMediaType:(WSMediaType)mediaType;

/**
 *   AdSpace will start playing a movie or a sound, you should react to this if you are playing audio or video in your app.
 *   <p>
 *   Example usage: You should make sure your users do not have a bad user experience where they hear two sounds at the same time while the ad is playing its media.
 *   </p>
 *   @param adSpace The AdSpace that has the ad with the media that will start to play.
 *   @param mediaType String describing the media type being started.
 *   @warning Deprecated since 4.1 due to replacement method.
 */
- (void)willStartMedia:(WSAdSpace *)adSpace mediaType:(NSString *)mediaType DEPRECATED_ATTRIBUTE;

/**
 *   AdSpace will stop playing a movie or a sound, you should react to this if you where playing audio or video in your app before the ad started its media. This can occur if your users stop the playing of a video/sound or if the ad is closed.
 *   <p>
 *   Example usage: Now is the perfect time for you to resume your audio playing.
 *   </p>
 *   @param adSpace The AdSpace that has the ad with the media that stopped playing.
 *   @param mediaType Enum describing the media type that was stopped.
 *   @warning This method is NOT called when media completes, only when media forcefully stops.
 */
- (void)didStopMedia:(WSAdSpace *)adSpace withMediaType:(WSMediaType)mediaType;

/**
 *   AdSpace will stop playing a movie or a sound, you should react to this if you where playing audio or video in your app before the ad started its media. This can occur if your users stop the playing of a video/sound or if the ad is closed.
 *   <p>
 *   Example usage: Now is the perfect time for you to resume your audio playing.
 *   </p>
 *   @param adSpace The AdSpace that has the ad with the media that stopped playing.
 *   @param mediaType String describing the media type that was stopped.
 *   @warning Deprecated since 4.1 due to replacement method.
 */
- (void)didStopMedia:(WSAdSpace *)adSpace mediaType:(NSString *)mediaType DEPRECATED_ATTRIBUTE;

/**
 *   AdSpace completed media playing. This happens when a video or audio plays its full length (ex. watching a video ad to the end of the video) or if media playback fails.
 *   @param adSpace The AdSpace has the ad with the media that completed playing.
 *   @param mediaType Enum describing the media type that completed.
 */
- (void)didCompleteMedia:(WSAdSpace *)adSpace withMediaType:(WSMediaType)mediaType;

/**
 *   AdSpace completed media playing. This happens when a video or audio plays its full length (ex. watching a video ad to the end of the video) or if media playback fails.
 *   @param adSpace The AdSpace has the ad with the media that completed playing.
 *   @param mediaType String describing the media type that completed.
 *   @warning Deprecated since 4.1 due to replacement method.
 */
- (void)didCompleteMedia:(WSAdSpace *)adSpace mediaType:(NSString *)mediaType DEPRECATED_ATTRIBUTE;

/**
 *   AdSpace will open full screen modal view (ex. full screen web browser, full screen video player & full screen calendar UI etc.).
 *   @param adSpace The AdSpace that will open full screen modal view.
 *   @available since 4.3.0
 *   @see didDismissModal:
 */
- (void)willPresentModal:(WSAdSpace *)adSpace;

/**
 *   AdSpace did dismiss full screen modal view.
 *   @param adSpace The AdSpace that did dismiss full screen modal view.
 *   @available since 4.3.0
 *   @see willPresentModal:
 */
- (void)didDismissModal:(WSAdSpace *)adSpace;

/**
 *   AdSpace did not receive any ad from engine (response returned but with no ad), this might be due to impressions already beeing consumed for your AdSpace.
 *   @param adSpace The AdSpace that received no ad.
 *   @warning This is not considered as an error.
 */
- (void)didReceiveNoAd:(WSAdSpace *)adSpace;

/**
 *   AdSpace failed and is reporting an error, if this happens you should check what error it is and try to handle it.
 *   <p>
 *   Its typically a bad idea to just propagate the error messages that comes through here to the user since the cause of the error most likely is not the users fault or nothing the user can do anything about. The WSAdSpace will try to handle the error.
 *   </p>
 *   @param adSpace The AdSpace that received the error.
 *   @param type Enum describing the error type.
 *   @param message Error description.
 *   @param error Underlying error.
 */
- (void)didFailWithError:(WSAdSpace *)adSpace withType:(WSErrorType)type message:(NSString *)message error:(NSError *)error;

/**
 *   AdSpace failed and is reporting an error, if this happens you should check what error it is and try to handle it.
 *   <p>
 *   Its typically a bad idea to just propagate the error messages that comes through here to the user since the cause of the error most likely is not the users fault or nothing the user can do anything about. The WSAdSpace will try to handle the error.
 *   </p>
 *   @param adSpace The AdSpace that received the error.
 *   @param type String describing the error type.
 *   @param message Error description.
 *   @param error Underlying error.
 *   @warning Deprecated since 4.1 due to replacement method.
 */
- (void)didFailWithError:(WSAdSpace *)adSpace type:(NSString *)type message:(NSString *)message error:(NSError *)error DEPRECATED_ATTRIBUTE;

/**
 *   Current ad in AdSpace was expanded.
 *   @param adSpace The AdSpace holds the ad that was expanded.
 *   @param expandDirection Enum describing the direction, in which direction the adspace expanded.
 *   @param finalWidth Width after ad has expanded.
 *   @param finalHeight Height after ad has expanded.
 */
- (void)didExpandAd:(WSAdSpace *)adSpace withExpandDirection:(WSAnimationDirection)expandDirection finalWidth:(CGFloat)finalWidth finalHeight:(CGFloat)finalHeight;

/**
 *   Current ad in AdSpace was expanded.
 *   @param adSpace The AdSpace holds the ad that was expanded.
 *   @param expandDirection String describing the direction, in which direction the adspace expanded.
 *   @param finalWidth Width after ad has expanded.
 *   @param finalHeight Height after ad has expanded.
 *   @warning Deprecated since 4.1 due to replacement method.
 */
- (void)didExpandAd:(WSAdSpace *)adSpace expandDirection:(NSString *)expandDirection finalWidth:(CGFloat)finalWidth finalHeight:(CGFloat)finalHeight DEPRECATED_ATTRIBUTE;

/**
 *   Current ad in AdSpace was resized.
 *   @param adSpace The AdSpace holds the ad that was resized.
 *   @param finalWidth Width after ad has resized.
 *   @param finalHeight Height after ad has resized.
 */
- (void)didResizeAd:(WSAdSpace *)adSpace finalWidth:(CGFloat)finalWidth finalHeight:(CGFloat)finalHeight;

/**
 *   Current ad in AdSpace was collapsed.
 *   @param adSpace The AdSpace holds the ad that was collapsed.
 *   @param collapsedDirection Enum describing the direction, in which direction the adspace collapsed.
 *   @param finalWidth Width after ad has collapsed.
 *   @param finalHeight Height after ad has collapsed.
 */
- (void)didCollapseAd:(WSAdSpace *)adSpace withCollapsedDirection:(WSAnimationDirection)collapsedDirection finalWidth:(CGFloat)finalWidth finalHeight:(CGFloat)finalHeight;

/**
 *   Current ad in AdSpace was collapsed.
 *   @param adSpace The AdSpace holds the ad that was collapsed.
 *   @param collapsedDirection String describing the direction, in which direction the adspace collapsed.
 *   @param finalWidth Width after ad has collapsed.
 *   @param finalHeight Height after ad has collapsed.
 *   @warning Deprecated since 4.1 due to replacement method.
 */
- (void)didCollapseAd:(WSAdSpace *)adSpace collapsedDirection:(NSString *)collapsedDirection finalWidth:(CGFloat)finalWidth finalHeight:(CGFloat)finalHeight DEPRECATED_ATTRIBUTE;

/**
 *   AdSpace finished prefetching an ad. The ad is placed in the ad queue and is ready for you to show using runAd.
 *
 *   <p>
 *   Available WSMediaStatus responses:<br>
 *   WSMediaStatusNoMedia           = Ad contains no media (regular ad)<br>
 *   WSMediaStatusMediaCached       = Ad contains media and media is cached<br>
 *   WSMediaStatusMediaNotCached    = Ad contains media but media is not cached<br>
 *   </p>
 *
 *   @param adSpace The AdSpace that prefetched an ad.
 *   @param mediaStatus Enum describing the status of media what media the ad contains. (not cached, cached or no media).
 */
- (void)didPrefetchAd:(WSAdSpace *)adSpace withMediaStatus:(WSMediaStatus)mediaStatus;

/**
 *   AdSpace finished prefetching an ad. The ad is placed in the ad queue and is ready for you to show using runAd.
 *
 *   <p>
 *   Available mediaStatus responses:<br>
 *   NO_MEDIA                       = Ad contains no media (regular ad)<br>
 *   MEDIA_CACHED                   = Ad contains media and media is cached<br>
 *   MEDIA_NOT_CACHED               = Ad contains media but media is not cached<br>
 *   </p>
 *
 *   @param adSpace The AdSpace that prefetched an ad.
 *   @param mediaStatus String describing the status of media what media the ad contains. (not cached, cached or no media).
 *   @warning Deprecated since 4.1 due to replacement method.
 */
- (void)didPrefetchAd:(WSAdSpace *)adSpace mediaStatus:(NSString *)mediaStatus DEPRECATED_ATTRIBUTE;

/**
 *   AdSpace will perform an in animation of an ad.
 *   @param adSpace The AdSpace that will animate an ad.
 */
- (void)willAnimateIn:(WSAdSpace *)adSpace;

/**
 *   AdSpace completed in animation of an ad.
 *   @param adSpace The AdSpace that completed the animation of an ad.
 */
- (void)didAnimateIn:(WSAdSpace *)adSpace;

/**
 *   AdSpace will perform an out animation of an ad.
 *   @param adSpace The AdSpace that will animate an ad.
 */
- (void)willAnimateOut:(WSAdSpace *)adSpace;

/**
 *   AdSpace completed out animation of an ad.
 *   @param adSpace The AdSpace that completed the animation of an ad.
 */
- (void)didAnimateOut:(WSAdSpace *)adSpace;

@end
