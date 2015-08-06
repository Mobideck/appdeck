//
//  FlurryMPConfig.h
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Flurry.h"

#define FlurryAPIKey @"YOUR API KEY HERE"
#define FlurryMediationOrigin @"Flurry_Mopub_iOS"
#define FlurryAdapterVersion @"6.4.0.r1"

/*
 * Provde adSpaceName param when configuring Flurry as the Custom Native Network
 * in the MoPub web interface {"adSpaceName": "YOUR_FLURRY_AD_SPACE_NAME"}.
 * If adSpaceName is not found, this adapter will use "BANNER_AD" as the Flurry ad space name.
 */
#define FlurryBannerAdSpaceName @"BANNER_AD"
#define FlurryBannerAdPlacement BANNER_BOTTOM

/*
 * Provde adSpaceName param when configuring Flurry as the Custom Native Network
 * in the MoPub web interface {"adSpaceName": "YOUR_FLURRY_AD_SPACE_NAME"}.
 * If adSpaceName is not found, this adapter will use "TAKOVER_AD" as the Flurry ad space name
 */
#define FlurryInterstitialAdSpaceTakeoverName @"TAKOVER_AD"
#define FlurryInterstitialAdPlacement FULLSCREEN

@interface FlurryMPConfig : NSObject

+ (id)sharedInstance;

@end
