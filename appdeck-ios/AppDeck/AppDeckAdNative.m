//
//  AppDeckAdNative.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 18/09/2015.
//  Copyright © 2015 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeckAdNative.h"

#import "ManagedWebView.h"
#import "LoaderViewController.h"
#import "AppDeck.h"

@implementation AppDeckAdNative

- (instancetype)init
{
    self = [super init];
    if (self) {
        /*
        self.adRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"062e493d055c4a6784b4d4a902da06c4"]; // UFB
        //self.adRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"76a3fefaced247959582d2d2df6f4757"]; // mopub

        MPNativeAdRequestTargeting *targeting = [MPNativeAdRequestTargeting targeting];
        // The constants correspond to the 6 elements of MoPub native ads
        targeting.desiredAssets = [NSSet setWithObjects:kAdTitleKey, kAdTextKey, kAdCTATextKey, kAdIconImageKey, kAdMainImageKey, kAdStarRatingKey, nil];
        
        [self.adRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *resp, NSError *error) {
            if (error == nil)
            {
                resp.delegate = self;                
                response = resp;
                [self injectInApiCalls];
            }
        }];*/

    }
    return self;
}

-(BOOL)addApiCall:(AppDeckApiCall *)apiCall
{
    if (apiCalls == nil)
        apiCalls = [[NSMutableArray alloc] init];
    
    [apiCalls addObject:apiCall];
    /*if (response != nil)
        [self injectInApiCalls];*/
    return YES;
}

-(BOOL)injectInApiCalls
{
    NSError *error;
    /*
    for (AppDeckApiCall *apiCall in apiCalls)
    {
        @try {
            NSString *divId = [NSString stringWithFormat:@"%@", [apiCall.param objectForKey:@"id"]];
            NSData *propertiesJsonData = [NSJSONSerialization dataWithJSONObject:response.properties options:NSJSONWritingPrettyPrinted error:&error];
            NSString *propertiesJson = [[NSString alloc] initWithData:propertiesJsonData encoding:NSUTF8StringEncoding];
            NSString *javascript = [NSString stringWithFormat:@"app.injectNativeAd('%@', %@);", divId, propertiesJson];
            [apiCall.managedWebView executeJS:javascript];
            [response trackImpression];
        }
        @catch (NSException *exception) {
            NSLog(@"AppDeckAdNative: Exception while writing JSon: %@", exception);
        }
    }
    [apiCalls removeAllObjects];*/
    return YES;
}


-(BOOL)click:(UIViewController *)root
{/*
    [response displayContentWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"NativeAdClickResult: %d: %@", success, error);
    }];*/
    return YES;
}

#pragma mark - MPNativeAdDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return [[AppDeck sharedInstance] loader];
}

@end
