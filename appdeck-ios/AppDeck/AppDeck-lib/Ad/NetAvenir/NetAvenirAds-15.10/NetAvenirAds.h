//
//  NetAvenirAds.h
//  Oxom
//
//  Created by Sébastien Sans on 08/06/2015.
//  Copyright (c) 2015 NetAvenir. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for NetAvenirAds.
FOUNDATION_EXPORT double NetAvenirAdsVersionNumber;

//! Project version string for NetAvenirAds.
FOUNDATION_EXPORT const unsigned char NetAvenirAdsVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NetAvenirAds/PublicHeader.h>


/*!
 * @protocol ADInterstitialAdDelegate
 */
@protocol NAAdPlacementDelegate <NSObject>

/*!
 * @method didReceiveAd:
 *
 * @discussion
 * Called when an adapter did receive ad.
 */
- (void)didReceiveAd;

/*!
 * @method didFailToReceiveAd:
 *
 * @discussion
 * Called when an adapter did fail to receive ad.
 *
 */
- (void)didFailToReceiveAd;

/*!
 * @method didDismissAd:
 *
 * @discussion
 * Called when an adapter did dismiss an ad.
 *
 */
- (void)didDismissAd;

@end

#import "NAAdTypes.h"
#import "NAAdPlacement.h"
