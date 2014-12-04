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

typedef NS_ENUM(NSInteger, SASSkipPosition) {
	SASSkipTopLeft,
	SASSkipTopRight,
	SASSkipBottomLeft,
	SASSkipBottomRight,
};

typedef NS_ENUM(NSInteger, SASCreativeType) {
	SASCreativeTypeImage,
	SASCreativeTypeAudio,
	SASCreativeTypeVideo,
	SASCreativeTypeHtml,
	SASCreativeTypeMRAIDAdSecondPart
};


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

@end
