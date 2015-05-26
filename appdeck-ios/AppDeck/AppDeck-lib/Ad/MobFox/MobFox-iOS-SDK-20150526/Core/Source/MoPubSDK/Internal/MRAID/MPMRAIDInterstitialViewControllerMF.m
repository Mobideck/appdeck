//
//  MPMRAIDInterstitialViewController.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPMRAIDInterstitialViewControllerMF.h"
#import "MPInstanceProviderMF.h"
#import "MPAdConfigurationMF.h"

@interface MPMRAIDInterstitialViewControllerMF ()

@property (nonatomic, retain) MRAdViewMF *interstitialView;
@property (nonatomic, retain) MPAdConfigurationMF *configuration;
@property (nonatomic, assign) BOOL advertisementHasCustomCloseButton;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPMRAIDInterstitialViewControllerMF

@synthesize delegate = _delegate;
@synthesize interstitialView = _interstitialView;
@synthesize configuration = _configuration;
@synthesize advertisementHasCustomCloseButton = _advertisementHasCustomCloseButton;

- (id)initWithAdConfiguration:(MPAdConfigurationMF *)configuration
{
    self = [super init];
    if (self) {
        CGFloat width = MAX(configuration.preferredSize.width, 1);
        CGFloat height = MAX(configuration.preferredSize.height, 1);
        CGRect frame = CGRectMake(0, 0, width, height);
        self.interstitialView = [[MPInstanceProviderMF sharedProvider] buildMRAdViewWithFrame:frame
                                                                            allowsExpansion:NO
                                                                           closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                                              placementType:MRAdViewPlacementTypeInterstitial
                                                                                   delegate:self];
        
        self.interstitialView.adType = configuration.precacheRequired ? MRAdViewAdTypePreCached : MRAdViewAdTypeDefault;
        self.configuration = configuration;
        self.orientationType = [self.configuration orientationType];
        self.advertisementHasCustomCloseButton = NO;
    }
    return self;
}

- (void)dealloc
{
    self.interstitialView.delegate = nil;
    self.interstitialView = nil;
    self.configuration = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.interstitialView.frame = self.view.bounds;
    self.interstitialView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.interstitialView];
}

#pragma mark - Public

- (void)startLoading
{
    [self.interstitialView loadCreativeWithHTMLString:[self.configuration adResponseHTMLString]
                                              baseURL:nil];
}

- (BOOL)shouldDisplayCloseButton
{
    return !self.advertisementHasCustomCloseButton;
}

- (void)willPresentInterstitial
{
    if ([self.delegate respondsToSelector:@selector(interstitialWillAppear:)]) {
        [self.delegate interstitialWillAppear:self];
    }
}

- (void)didPresentInterstitial
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidAppear:)]) {
        [self.delegate interstitialDidAppear:self];
    }
}

- (void)willDismissInterstitial
{
    if ([self.delegate respondsToSelector:@selector(interstitialWillDisappear:)]) {
        [self.delegate interstitialWillDisappear:self];
    }
}

- (void)didDismissInterstitial
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidDisappear:)]) {
        [self.delegate interstitialDidDisappear:self];
    }
}

#pragma mark - MRAdViewDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (MPAdConfigurationMF *)adConfiguration
{
    return self.configuration;
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adDidLoad:(MRAdViewMF *)adView
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidLoadAd:)]) {
        [self.delegate interstitialDidLoadAd:self];
    }
}

- (void)adDidFailToLoad:(MRAdViewMF *)adView
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToLoadAd:)]) {
        [self.delegate interstitialDidFailToLoadAd:self];
    }
}

- (void)adWillClose:(MRAdViewMF *)adView
{
    [self dismissInterstitialAnimated:YES];
}

- (void)adDidClose:(MRAdViewMF *)adView
{
    // TODO:
}

- (void)ad:(MRAdViewMF *)adView didRequestCustomCloseEnabled:(BOOL)enabled
{
    self.advertisementHasCustomCloseButton = enabled;
    [self layoutCloseButton];
}

- (void)appShouldSuspendForAd:(MRAdViewMF *)adView
{

}

- (void)appShouldResumeFromAd:(MRAdViewMF *)adView
{

}

@end
