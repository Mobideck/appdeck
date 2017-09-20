//
//  AppDeckAdNative.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 18/09/2015.
//  Copyright © 2015 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDeckApiCall.h"
/*#import "MPNativeAd.h"
#import "MPNativeAdDelegate.h"
#import "MPNativeAdRequest.h"
#import "MPNativeAdRequestTargeting.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdRendering.h"*/

@interface AppDeckAdNative : NSObject //<MPNativeAdDelegate>
{
    NSMutableArray *apiCalls;
    //MPNativeAd *response;
    BOOL ready;
}
@property (nonatomic, retain) NSString *divId;
//@property (nonatomic, retain) MPNativeAdRequest *adRequest;
@property (nonatomic, weak) AppDeckApiCall *apiCall;


-(BOOL)addApiCall:(AppDeckApiCall *)call;

-(BOOL)click:(UIViewController *)root;

@end
