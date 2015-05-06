//
//  SASAd.h
//  SmartAdServer
//
//  Created by Clémence Laurent on 03/06/14.
//
//

/**
 A SASAd object represents an ad's data, as it has been programmed in the Smart AdServer Manage interface.
 You can check some values like the width and the height to adapt your app's behavior to it.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
	SASSkipTopLeft,
	SASSkipTopRight,
	SASSkipBottomLeft,
	SASSkipBottomRight,
} SASSkipPosition;

typedef enum {
	SASCreativeTypeImage,
	SASCreativeTypeAudio,
	SASCreativeTypeVideo,
	SASCreativeTypeHtml,
	SASCreativeTypeMRAIDAdSecondPart
} SASCreativeType;


@class SASMediationAd;
@interface SASAd : NSObject <NSCopying, NSCoding>

///--------------------
/// @name Ad properties
///--------------------


/** The original portrait creative size.
 
 */

@property (nonatomic, readonly) CGSize portraitSize;


/** The original portrait creative size.
 
 */

@property (nonatomic, readonly) CGSize landscapeSize;


/** The currently displayed mediation ad.
 
 */

@property (nonatomic, readonly) SASMediationAd *currentMediationAd;


/** The array of mediation ads returned by the server.
 
 */

@property (nonatomic, readonly) NSArray *mediationAds;

@end
