//
//  SmartAdServerAd.h
//  SmartAdServer
//
//  Created by Julien Stoeffler on 06/01/10.
//  Copyright 2010 Smart AdServer. All rights reserved.
//

/** 
A SmartAdServerAd object represents an ad's data, as it has been programmed in the Smart AdServer Manage interface.
You can create one of those objects if you need to display an offline ad as follows:
 
	SmartAdServerAd * ad = [[SmartAdServerAd alloc] init];
    ad.creativeURL = portraitUrl;
	ad.creativeLandscapeUrl = landscapeUrl;
	[banner displayThisAd:ad];
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SASAd.h" // This import is only useful to import defines and enums

#define SkipPosition SASSkipPosition
#define SkipTopLeft SASSkipTopLeft
#define SkipTopRight SASSkipTopRight
#define SkipBottomLeft SASSkipBottomLeft
#define SkipBottomRight SASSkipBottomRight

#define CreativeType SASCreativeType
#define CreativeTypeImage SASCreativeTypeImage
#define CreativeTypeAudio SASCreativeTypeAudio
#define CreativeTypeVideo SASCreativeTypeVideo
#define CreativeTypeHtml SASCreativeTypeHtml
#define CreativeTypeMRAIDAdSecondPart SASCreativeTypeMRAIDAdSecondPart


@interface SmartAdServerAd : NSObject <NSCopying, NSCoding>

///--------------------
/// @name Ad properties
///--------------------

/** The time during which your ad will stay in place
 
 The timer starts when the creative is loaded
 This value is not used for with a SmartAdServerView set to unlimited (banners, toasters,...)
 
 */

@property float duration;


/** The ad's background color.
  
 */

@property (nonatomic, retain) UIColor *backgroundColor;


/** The creative displayed in portrait mode.
 
 */

@property (nonatomic, retain) NSURL *creativeURL;


/** The creative displayed in portrait mode.
 
 */

@property (nonatomic, retain) NSURL *creativeLandscapeUrl;


/** The URL called when the ad is clicked, for the ad action.
 
 */

@property (nonatomic, retain) NSURL *redirectURL;


/** The URL called when the ad (landscape creative if exists) is clicked, for the ad action.
 
 */
@property (nonatomic, retain) NSURL *redirectLandscapeURL;


/** The URL called when the ad is clicked for statistics.
 
 */

@property (nonatomic, retain) NSURL *countURL;


/** The URL called when the ad (landscape creative if exists) is clicked, for statistics.
 
 */

@property (nonatomic, retain) NSURL *countLandscapeURL;


/** The impression pixel URL to count the number of impressions.
 
 */

@property (nonatomic, retain) NSURL *impPixel;


/** The impression pixel URL in landscape mode, to count the number of impressions.
 
 */

@property (nonatomic, retain) NSURL *impLandscapePixel;


/** The impression pixel URL to count the number of impressions.
 
 */

@property (nonatomic, retain) NSArray *agencyPortraitPixels;


/** The impression pixel URL in landscape mode, to count the number of impressions.
 
 */

@property (nonatomic, retain) NSArray *agencyLandscapePixels;


/** The text displayed on the "trigger" button of an expand ad.
 
 */

@property (nonatomic, retain) NSString *text;


/** The color of the text displayed on the "trigger" button of an expand ad.
 
 */

@property (nonatomic, retain) UIColor *textColor;


/** A boolean value which specifies whether it should be expanded when loaded.
 
 Only used if the ad is in expand format.
 */

@property (nonatomic, getter = isExpandedAtInit) BOOL expandedAtInit;


/** A boolean value which specifies whether the ad is in expand format.
 
 Only used if the ad is in expand format (its height changes with animated effect).
 
 */

@property (nonatomic, getter = isExpand) BOOL expand;


/** A boolean value which specifies if the WebView displaying the ad's redirect URL has controls.
 
 Those controls are "Previous/Next", "Safari" and "Back".
 
 */

@property (nonatomic, getter = hasNavigationControls) BOOL navigationHasControls;


/** A boolean value which specifies whether the ad should expand from top.
 
 Only used if the ad is in expand format.
 
 */

@property (nonatomic, getter = isExpandedFromTop) BOOL fromTop;


/** A boolean value which specifies whether the ad has a transparent background.
 
 */

@property (nonatomic, getter = hasTransparentBackground) BOOL transparentBackground;


/** A boolean value which specifies whether the ad asks the user if he wants to quit the app when a third party app is called.
 
 */

@property BOOL askConfirmationBeforeClosingApp;


/** A boolean value which specifies whether the video ad should auto-play.
 
 */

@property BOOL videoAutoPlay;


/** A boolean value which specifies whether the ad has a skip button.
 
 */

@property (nonatomic, getter = hasSkip) BOOL skip;


/** A boolean value which specifies whether the ad's will redirect to the App Store/YouTube/...
 
 */

@property BOOL redirectsToThirdParty;


/** The button's skip position. The possible values are:
 
	 typedef enum {
		 SASSkipTopLeft,
		 SASSkipTopRight,
		 SASSkipBottomLeft,
		 SASSkipBottomRight,
	 } SASSkipPosition;
 
 `SASSkipTopLeft`
 
 Default skip position to the top-left corner.
 
 `SASSkipTopRight`
 
 Skip position to the top-right corner.
 
 `SASSkipBottomLeft`
 
 Skip position to the bottom-left corner.
 
 `SASSkipBottomRight`
 
 Skip position to the bottom-right corner.
 
 */

@property SASSkipPosition skipPosition;


/** Set to YES when the skipPosition has been defined manually.
 
 */

@property (nonatomic, getter = isSkipPositionDefinedSkip) BOOL skipPositionDefined;


/** An integer specifying the ad's creative type (image, HTML). The possible values are:
 
	 typedef enum {
		 SASCreativeTypeImage,
		 SASCreativeTypeAudio,
		 SASCreativeTypeVideo,
		 SASCreativeTypeHtml,
		 SASCreativeTypeMRAIDAdSecondPart
	 } SASCreativeType;
 
 `SASCreativeTypeImage`
 
 Default creative type is an image file.
 
 `SASCreativeTypeAudio`
 
 Creative type is an audio file.
 
 `SASCreativeTypeVideo`
 
 Creative type is an video file.
 
 `SASCreativeTypeHtml`
 
 Creative type is an HTML file.
 
 `SASCreativeTypeMRAIDAdSecondPart`
 
 Creative type is an MRAID second part ad file.
 
 */

@property SASCreativeType creativeType;


/** An HTML script to load in case of an HTML creative type.
 
 */

@property (nonatomic, retain) NSString *creativeScript;


/** The URL to the HTML script to load in case of an HTML creative type.
 
 */

@property (nonatomic, retain) NSURL *creativeScriptURL;


/** An HTML script to load in case of an HTML creative type.
 
 */

@property (nonatomic, assign, getter = isOffline) BOOL offline;


/** A data connection is needed to display this ad, even if it is a prefetched creative.
 
 */

@property (nonatomic, assign, getter = isConnectionNeeded) BOOL connectionNeeded;

/** The desired expanded height, in protrait orientation, for a toaster.
 
 */

@property CGFloat expandedHeight;

/** The desired expanded height, in landscape orientation, for a toaster.
 
 */

@property CGFloat expandedLandscapeHeight;


/** Whether the standard trigger should be added.
 
 */

@property BOOL addStandardTrigger;


/** The desired height of the trigger zone, for a toaster.
 
 */

@property CGFloat triggerHeight;


/** The desired height of the trigger zone, in landscape orientation, for a toaster.
 
 */

@property CGFloat triggerLandscapeHeight;


/** The original portrait image size.
 
 */

@property CGSize imageSize;


/** The original landscape image size.
 
 */

@property CGSize landscapeImageSize;


/** The original portrait creative size.
 
 */

@property CGSize portraitSize;


/** The original portrait creative size.
 
 */

@property CGSize landscapeSize;


/** The original video size.
 
 */

@property  CGSize videoSize;


/** The expiration date for offline ads.
 
 */

@property (nonatomic, retain) NSDate *expirationDate;


/** The insertion ID.
 
 */

@property (assign) NSInteger insertionId;


/** A boolean value which specifies whether the ad transfers touch events to the lower view.
 
 */

@property BOOL transferTouchEvents;

@end
