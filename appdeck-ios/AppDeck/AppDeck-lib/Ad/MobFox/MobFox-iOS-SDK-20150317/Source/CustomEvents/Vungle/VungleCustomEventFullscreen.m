//
//  VungleCustomEventFullscreen.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 18.06.2014.
//
//

#import "VungleCustomEventFullscreen.h"


@implementation VungleCustomEventFullscreen

- (void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    
    Class SDKClass = NSClassFromString(@"VungleSDK");
    if(!SDKClass) {
        [self notifyAdFailed];
        return;
    }
    sdk = [SDKClass sharedSDK];
    [sdk startWithAppId:optionalParameters];
    [sdk setDelegate:self];
    
    if([sdk isCachedAdAvailable]) {
        [self notifyAdLoaded];
    } else {
        checkStatusTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkVungleReady) userInfo:nil repeats:NO]; //hack, Vungle doesn't provide delegate method  notifying about ad load status
    }
}

- (void)showFullscreenFromRootViewController:(UIViewController *)rootViewController
{
    if(sdk) {
        [sdk playAd:rootViewController];
    }
}

- (void)vungleSDKwillShowAd {
    [self notifyAdWillAppear];
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary*)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet {
    if(!willPresentProductSheet) {
        if([viewInfo[@"didDownload"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
            [self notifyAdWillLeaveApplication];
        }
        
        [self notifyAdWillClose];
    }
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet {
    [self notifyAdWillClose];
}

- (void)checkVungleReady {
    if(sdk && [sdk isCachedAdAvailable]) {
        [self notifyAdLoaded];
    } else {
        [self notifyAdFailed];
    }
}

- (void)dealloc
{
    if(checkStatusTimer) {
        [checkStatusTimer invalidate];
    }
    checkStatusTimer = nil;

    sdk = nil;
    
}

-(void)finish {
    if(checkStatusTimer) {
        [checkStatusTimer invalidate];
    }
    checkStatusTimer = nil;
    
    if(sdk) {
        [sdk setDelegate:nil];
    }
    sdk = nil;
    [super finish];
}


@end
