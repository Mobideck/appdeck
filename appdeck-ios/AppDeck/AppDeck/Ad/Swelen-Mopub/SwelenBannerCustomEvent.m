//
//  SwelenBannerCustomEvent.m
//  Swelen support for Mopub
//
//  Author : benoit@pereira-da-silva.com
//  Copyright (c) 2014 Azurgate SAS All rights reserved.
//

#import "SwelenBannerCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPConstants.h"
#import "MPLogging.h"

@interface SwelenBannerCustomEvent (){
}
@property (nonatomic,strong)swAdView *banner;
@end

@implementation SwelenBannerCustomEvent
@synthesize banner=_banner;
    
    
#pragma mark - MPBannerCustomEvent Subclass Methods
    
- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info{
    MPLogDebug(@"Requesting Swelen banner");
	NSString * slotId = [info objectForKey:@"adUnitID"];
    if (slotId && ![slotId isEqualToString:@""]) {
		self.banner=[[swAdView alloc] initWithSlot:slotId andSize:size];
		_banner.delegate=self;
    }
    [_banner loadAd];
}
    
#pragma mark - swelenDelegate
    
- (void) swAdVideoDidStartPlaying{
    MPLogInfo(@"swAdVideoDidStartPlaying");
}
- (void) swAdVideoDidStopPlaying{
    MPLogInfo(@"swAdVideoDidStopPlaying");
}
    
- (void)swAdDidFail:(swAdView *)slot args:(id)args{
    NSError*error=(NSError*)args;
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
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
    
- (void) swAdDidClose:(swAdView *)slot args:(id)args{
    [self.delegate bannerCustomEventDidFinishAction:self];
}
    
- (void) swAdDidReceiveClick:(swAdView *)slot args:(id)args{
    MPLogInfo(@"Swelen banner swAdDidReceiveClick");
    [self.delegate bannerCustomEventWillBeginAction:self];
}
    
- (void) swAdDidDisplay:(swAdView *)slot args:(id)args{
    MPLogDebug(@"SwelenForMopub Banner did load");
    [self.delegate trackImpression];
    [self.delegate bannerCustomEvent:self didLoadAd:slot];
	[_banner stopAd];
}
    
@end