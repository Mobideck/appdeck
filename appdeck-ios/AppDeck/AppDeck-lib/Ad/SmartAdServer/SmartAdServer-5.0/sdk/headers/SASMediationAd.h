//
//  SASMediationAd.h
//  SmartAdServer
//
//  Created by Clémence Laurent on 30/05/14.
//
//

/**
 A SASMediationAd object represents an ad which can be a Smart AdServer ad, as well as another ad server company's ad. 
 The currently supported SDK from other ad servers are the following:
 
 - InMobi iOS SDK 4.3.0
 - Millennial iOS Framework
 */

#import <Foundation/Foundation.h>



@interface SASMediationAd : NSObject <NSCopying, NSCoding>

///------------------------------
/// @name Mediation ad properties
///------------------------------

/** The identifier of the ad's SDK according to Smart classification.
 
 */

@property (nonatomic, assign) NSUInteger SDKID;


/** The required information by the ad's SDK.
 This can be seen as the equivalent to Smart AdServer's pageID or formatID, or else.
 
 */

@property (nonatomic, retain) NSDictionary *placementConfig;


/** The impression pixel URL called when the ad is displayed to count the number of impressions.
 
 */

@property (nonatomic, retain) NSURL *impressionURL;


/** The click pixel URL called when the ad is clicked to count the number of clicks.
 
 */

@property (nonatomic, retain) NSURL *countClickURL;

@end
