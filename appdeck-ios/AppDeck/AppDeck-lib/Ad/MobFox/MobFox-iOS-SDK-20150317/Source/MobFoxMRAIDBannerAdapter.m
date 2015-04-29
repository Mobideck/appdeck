#import "MobFoxMRAIDBannerAdapter.h"
#import "MPAdConfiguration.h"


@implementation MobFoxMRAIDBannerAdapter

@synthesize adView = _adView;
@synthesize configuration = _configuration;

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size
{
    CGRect adViewFrame = CGRectZero;
    if ([configuration hasPreferredSize]) {
        adViewFrame = CGRectMake(0, 0, configuration.preferredSize.width,
                                 configuration.preferredSize.height);
    }
    
    self.adView = [[MRAdView alloc] initWithFrame:adViewFrame
                                 allowsExpansion:YES
                                closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                   placementType:MRAdViewPlacementTypeInline];
    self.adView.delegate = self;

    self.configuration = configuration;
    [self.adView loadCreativeWithHTMLString:[configuration adResponseHTMLString]
                                baseURL:nil];
}

- (void)dealloc
{
    _adView.delegate = nil;
    _adView = nil;
    _configuration = nil;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.adView rotateToOrientation:newOrientation];
}

#pragma mark - MRAdViewControllerDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (MPAdConfiguration *)adConfiguration
{
    return self.configuration;
}

- (NSString *)adUnitId
{
    return nil;
}

- (CLLocation *)location {
    return nil;
}

- (void)adDidLoad:(MRAdView *)adView
{
    [self.delegate adapter:self didFinishLoadingAd:adView];
}

- (void)adDidFailToLoad:(MRAdView *)adView
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)appShouldSuspendForAd:(MRAdView *)adView
{
    [self.delegate userActionWillBeginForAdapter:self];
}

- (void)appShouldResumeFromAd:(MRAdView *)adView
{
    [self.delegate userActionDidFinishForAdapter:self];
}

@end
