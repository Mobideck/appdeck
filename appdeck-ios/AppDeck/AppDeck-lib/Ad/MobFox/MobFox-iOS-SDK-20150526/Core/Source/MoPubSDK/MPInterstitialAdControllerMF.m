//
//  MPInterstitialAdController.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialAdControllerMF.h"

#import "MpLoggingMF.h"
#import "MPInstanceProviderMF.h"
#import "MPInterstitialAdManagerMF.h"
#import "MPInterstitialAdManagerDelegateMF.h"

@interface MPInterstitialAdControllerMF () <MPInterstitialAdManagerDelegateMF>

@property (nonatomic, retain) MPInterstitialAdManagerMF *manager;

+ (NSMutableArray *)sharedInterstitials;
- (id)initWithAdUnitId:(NSString *)adUnitId;

@end

@implementation MPInterstitialAdControllerMF

@synthesize manager = _manager;
@synthesize delegate = _delegate;
@synthesize adUnitId = _adUnitId;
@synthesize keywords = _keywords;
@synthesize location = _location;
@synthesize testing = _testing;

- (id)initWithAdUnitId:(NSString *)adUnitId
{
    if (self = [super init]) {
        self.manager = [[MPInstanceProviderMF sharedProvider] buildMPInterstitialAdManagerWithDelegate:self];
        self.adUnitId = adUnitId;
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;

    [self.manager setDelegate:nil];
    self.manager = nil;

    self.adUnitId = nil;
    self.keywords = nil;
    self.location = nil;

    [super dealloc];
}

#pragma mark - Public

+ (MPInterstitialAdControllerMF *)interstitialAdControllerForAdUnitId:(NSString *)adUnitId
{
    NSMutableArray *interstitials = [[self class] sharedInterstitials];

    @synchronized(self) {
        // Find the correct ad controller based on the ad unit ID.
        MPInterstitialAdControllerMF *interstitial = nil;
        for (MPInterstitialAdControllerMF *currentInterstitial in interstitials) {
            if ([currentInterstitial.adUnitId isEqualToString:adUnitId]) {
                interstitial = currentInterstitial;
                break;
            }
        }

        // Create a new ad controller for this ad unit ID if one doesn't already exist.
        if (!interstitial) {
            interstitial = [[[[self class] alloc] initWithAdUnitId:adUnitId] autorelease];
            [interstitials addObject:interstitial];
        }

        return interstitial;
    }
}

- (BOOL)ready
{
    return self.manager.ready;
}

- (void)loadAd
{
    [self.manager loadInterstitialWithAdUnitID:self.adUnitId
                                      keywords:self.keywords
                                      location:self.location
                                       testing:self.testing];
}

- (void)showFromViewController:(UIViewController *)controller
{
    if (!controller) {
        MPLogWarnMF(@"The interstitial could not be shown: "
                  @"a nil view controller was passed to -showFromViewController:.");
        return;
    }
    
    if (![controller.view.window isKeyWindow]) {
        MPLogWarnMF(@"Attempted to present an interstitial ad in non-key window. The ad may not render properly");
    }

    [self.manager presentInterstitialFromViewController:controller];
}

#pragma mark - Internal

+ (NSMutableArray *)sharedInterstitials
{
    static NSMutableArray *sharedInterstitials;

    @synchronized(self) {
        if (!sharedInterstitials) {
            sharedInterstitials = [[NSMutableArray array] retain];
        }
    }

    return sharedInterstitials;
}

#pragma mark - MPInterstitialAdManagerDelegate

- (MPInterstitialAdControllerMF *)interstitialAdController
{
    return self;
}

- (id)interstitialDelegate
{
    return self.delegate;
}

- (void)managerDidLoadInterstitial:(MPInterstitialAdManagerMF *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidLoadAd:)]) {
        [self.delegate interstitialDidLoadAd:self];
    }
}

- (void)manager:(MPInterstitialAdManagerMF *)manager
        didFailToLoadInterstitialWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToLoadAd:)]) {
        [self.delegate interstitialDidFailToLoadAd:self];
    }
}

- (void)managerWillPresentInterstitial:(MPInterstitialAdManagerMF *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialWillAppear:)]) {
        [self.delegate interstitialWillAppear:self];
    }
}

- (void)managerDidPresentInterstitial:(MPInterstitialAdManagerMF *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidAppear:)]) {
        [self.delegate interstitialDidAppear:self];
    }
}

- (void)managerWillDismissInterstitial:(MPInterstitialAdManagerMF *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialWillDisappear:)]) {
        [self.delegate interstitialWillDisappear:self];
    }
}

- (void)managerDidDismissInterstitial:(MPInterstitialAdManagerMF *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidDisappear:)]) {
        [self.delegate interstitialDidDisappear:self];
    }
}

- (void)managerDidExpireInterstitial:(MPInterstitialAdManagerMF *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidExpire:)]) {
        [self.delegate interstitialDidExpire:self];
    }
}

#pragma mark - Deprecated

+ (NSMutableArray *)sharedInterstitialAdControllers
{
    return [[self class] sharedInterstitials];
}

+ (void)removeSharedInterstitialAdController:(MPInterstitialAdControllerMF *)controller
{
    [[[self class] sharedInterstitials] removeObject:controller];
}

- (void)customEventDidLoadAd
{
    [self.manager customEventDidLoadAd];
}

- (void)customEventDidFailToLoadAd
{
    [self.manager customEventDidFailToLoadAd];
}

- (void)customEventActionWillBegin
{
    [self.manager customEventActionWillBegin];
}

@end
