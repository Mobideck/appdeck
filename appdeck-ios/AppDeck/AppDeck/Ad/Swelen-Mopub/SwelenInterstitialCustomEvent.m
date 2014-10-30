//
//  SwelenInterstitialCustomEvent.m
//  Swelen support for Mopub
//
//  Author : benoit@pereira-da-silva.com
//  Copyright (c) 2014 Azurgate SAS All rights reserved.
//

#import "SwelenInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"

@interface SwelenInterstitialCustomEvent (){
}
@property (nonatomic, strong) swAdInterstitial *interstitial;
@end


@implementation SwelenInterstitialCustomEvent

@synthesize interstitial = _interstitial;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

    
- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info{
	MPLogDebug(@"Requesting Swelen interstitial");
	NSString * slotId = [info objectForKey:@"adUnitID"];
    if (slotId && ![slotId isEqualToString:@""]) {
        self.interstitial=[[swAdInterstitial alloc] initWithSlot:slotId];
        _interstitial.delegate=self;
		_interstitial.autoCloseAfterCountdown = YES;
		_interstitial.userCanCloseAfterDisplay = YES;
    }
    [_interstitial loadAd];
}

#pragma mark - swelenDelegateInterstitial
    
- (void) swAdInterstitialVideoDidStartPlaying {
    MPLogInfo(@"swAdInterstitialVideoDidStartPlaying");
}

- (void) swAdInterstitialVideoDidStopPlaying {
    MPLogInfo(@"swAdInterstitialVideoDidStopPlaying");
}

- (void) swAdInterstitialDidFail:(swAdInterstitial *)interstitial args:(id)args{
    NSError*error=(NSError*)args;
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    switch([error code]) {
        case SW_ERR_NOADS:
        MPLogWarn(@"SwelenForMopub No Ad to display on the current slot");
        break;
        case SW_ERR_CON:
        MPLogWarn(@"SwelenForMopub Connection error");
        break;
        case SW_ERR_ALREADY_RUNNING:
        MPLogWarn(@"SwelenForMopub  The Ad is already running");
        break;
        case SW_ERR_BLOCKED:
        MPLogWarn(@"SwelenForMopub  The Ad has been blocked (i.e. another modal or overlay ad is running)");
        break;
        case SW_ERR_INTERNAL:
        MPLogWarn(@"SwelenForMopub  Internal error");
        break;
        case SW_ERR_SLOT:
        MPLogWarn(@"SwelenForMopub  Slot UID not found");
        break;
        default:
        MPLogWarn(@"SwelenForMopub  Slot UID not found");
        break;
    }
}
    
    
- (void) swAdInterstitialDidClose:(swAdInterstitial *)interstitial args:(id)args{
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
    
}
    
- (void) swAdInterstitialDidReceiveClick:(swAdInterstitial *)interstitial args:(id)args{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void) swAdInterstitialDidDisplay:(swAdInterstitial *)interstitial args:(id)args{
	MPLogInfo(@"SwelenForMopub Did display interstitial");
    [self.delegate interstitialCustomEvent:self didLoadAd:interstitial];
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
    [self.delegate trackImpression];
}

@end
