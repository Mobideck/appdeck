//
//  MobFoxWaterfallBannerView.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 04.05.2015.
//
//

#import "MobFoxWaterfallBannerView.h"
#import "MobFoxBannerView.h"
#import "MobFoxNativeFormatCreativesManager.h"
#import "MobFoxNativeFormatView.h"
#import "MobFoxCreativesQueueManager.h"



@interface MobFoxWaterfallBannerView () <MobFoxBannerViewDelegate, MobFoxNativeFormatViewDelegate> {
}

@property (nonatomic, strong) MobFoxNativeFormatCreativesManager* nativeFormatCreativesManager;
@property (nonatomic, strong) MobFoxCreativesQueueManager* queueManager;
@property (nonatomic, strong) NSMutableArray* adQueue;
@property (nonatomic, strong) UIView* bannerView;

@end

@implementation MobFoxWaterfallBannerView

- (void)setup
{
    self.autoresizingMask = UIViewAutoresizingNone;
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

-(instancetype)init
{
    if ((self = [super init]))
    {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    self.adQueue = nil;
    self.queueManager = nil;
    self.nativeFormatCreativesManager = nil;
    [self cleanBannerView];
    self.delegate = nil;
}

-(void)setDelegate:(id<MobFoxWaterfallBannerViewDelegate>)delegate {
    _delegate = delegate;
    self.queueManager = [MobFoxCreativesQueueManager sharedManagerWithPublisherId:[self.delegate publisherIdForMobFoxWaterfallBannerView:self]];
    self.nativeFormatCreativesManager = [MobFoxNativeFormatCreativesManager sharedManagerWithPublisherId:[self.delegate publisherIdForMobFoxWaterfallBannerView:self]];
}

-(void)requestAd
{
    if (!self.delegate)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Delegate for waterfall banner not set!" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:MobFoxErrorDomain code:MobFoxErrorUnknown userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        return;
    }
    
    if(!self.adQueue) {
        self.adQueue = [self.queueManager getCreativesQueueForBanner];
    }
    if (self.adQueue.count < 1) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No ad types in queue!" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:MobFoxErrorDomain code:MobFoxErrorUnknown userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        return;
    }
    
    MobFoxCreative* chosenCreative = [self.queueManager getCreativeFromQueue:self.adQueue];
    
    switch (chosenCreative.type) {
        case MobFoxCreativeBanner: {
            [self requestClassicBanner];
            break;
        }
            
        case MobFoxCreativeNativeFormat: {
            [self requestNativeFormatBanner];
            break;
        }
            
        default: {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Chosen creative type not supported for banners!" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MobFoxErrorDomain code:MobFoxErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(bannerFailedWithError:) withObject:error waitUntilDone:YES];
        }
    }
    
}

- (void) requestNativeFormatBanner
{
    NSInteger width, height;
    if(self.adspaceHeight > 0 && self.adspaceWidth > 0)
    {
        height = self.adspaceHeight;
        width = self.adspaceWidth;
    }
    else if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        width = 728;
        height = 90;
    }
    else
    {
        width = 320;
        height = 50;
    }
    
    MobFoxNativeFormatCreative* chosenCreative = [self.nativeFormatCreativesManager getCreativeWithWidth:width andHeight:height];
    if (!chosenCreative) {
        NSString* errorString = [NSString stringWithFormat:@"Cannot find creative template for requested size: %li x %li", (long)width, (long)height];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
        NSError* error = [NSError errorWithDomain:MobFoxErrorDomain code:0 userInfo:userInfo];
        [self bannerFailedWithError:error];
        return;
    }
    MobFoxNativeFormatView* nativeFormatView = [[MobFoxNativeFormatView alloc]init];
    nativeFormatView.delegate = self;
    [nativeFormatView requestAdWithCreative:chosenCreative andPublisherId:[self.delegate publisherIdForMobFoxWaterfallBannerView:self]];
    self.bannerView = nativeFormatView;
}

-(void) requestClassicBanner {
    MobFoxBannerView* banner = [[MobFoxBannerView alloc] initWithFrame:self.frame];
    banner.allowDelegateAssigmentToRequestAd = NO;
    
    banner.delegate = self;
    banner.requestURL = @"http://my.mobfox.com/request.php";
    
    if(self.adspaceHeight > 0 && self.adspaceWidth > 0)
    {
        banner.adspaceHeight = self.adspaceHeight;
        banner.adspaceWidth = self.adspaceWidth;
    }
    banner.refreshTimerOff = YES;
    [banner requestAd];
    self.bannerView = banner;
}

- (void) cleanBannerView {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)showNewBanner:(UIView*)banner {
    [self cleanBannerView];
    self.bounds = banner.bounds;
    
    [self insertSubview:banner atIndex:0];

    [self reportSuccess];
    
}

-(void)setCenter:(CGPoint)center
{
    [super setCenter:center];
    for (UIView *oneView in self.subviews)
    {
        oneView.center = CGPointMake(roundf(self.bounds.size.width / 2.0), roundf(self.bounds.size.height / 2.0));
        oneView.bounds = self.bounds; //for classic banner view to move its subviews correctly
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    for (UIView *oneView in self.subviews)
    {
        oneView.center = CGPointMake(roundf(self.bounds.size.width / 2.0), roundf(self.bounds.size.height / 2.0));
        oneView.bounds = self.bounds;
    }
}

- (void)reportSuccess
{
    self.adQueue = nil;
    if ([self.delegate respondsToSelector:@selector(mobfoxWaterfallBannerViewDidLoadMobFoxAd:)])
    {
        [self.delegate mobfoxWaterfallBannerViewDidLoadMobFoxAd:self];
    }
}

- (void)reportError:(NSError *)error
{
    self.adQueue = nil;
    if ([self.delegate respondsToSelector:@selector(mobfoxWaterfallBannerViewDidFailToReceiveAdWithError:)])
    {
        [self.delegate mobfoxWaterfallBannerViewDidFailToReceiveAdWithError:error];
    }
}

- (void)reportViewActionWillPresent {
    if ([self.delegate respondsToSelector:@selector(mobfoxWaterfallBannerViewActionWillPresent)]) {
        [self.delegate mobfoxWaterfallBannerViewActionWillPresent];
    }
}

- (void)reportViewActionWillFinish {
    if ([self.delegate respondsToSelector:@selector(mobfoxWaterfallBannerViewActionWillFinish)]) {
        [self.delegate mobfoxWaterfallBannerViewActionWillFinish];
    }
}

- (void)bannerFailedWithError:(NSError *)error
{
    if(self.adQueue.count > 0) {
        [self requestAd];
    } else {
        [self reportError:error];
    }
}


#pragma mark Banner View delegate
- (NSString *)publisherIdForMobFoxBannerView:(MobFoxBannerView *)banner {
    return [self.delegate publisherIdForMobFoxWaterfallBannerView:self];
}

- (void)mobfoxBannerViewDidLoadMobFoxAd:(MobFoxBannerView *)banner {
    [self showNewBanner:banner];
}

- (void)mobfoxBannerViewDidLoadRefreshedAd:(MobFoxBannerView *)banner {
    [self showNewBanner:banner];
}

- (void)mobfoxBannerView:(MobFoxBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self bannerFailedWithError:error];
}

- (void)mobfoxBannerViewActionWillPresent:(MobFoxBannerView *)banner {
    [self reportViewActionWillPresent];
}

- (void)mobfoxBannerViewActionWillFinish:(MobFoxBannerView *)banner {
    [self reportViewActionWillFinish];
}

#pragma mark Native Format View delegate

- (void)mobfoxNativeFormatDidLoad:(MobFoxNativeFormatView *)nativeFormatView {
    [self showNewBanner:nativeFormatView];
}

- (void)mobfoxNativeFormatDidFailToLoadWithError:(NSError *)error {
    [self bannerFailedWithError:error];
}

- (void)mobfoxNativeFormatWillPresent {
    [self reportViewActionWillPresent];
}

- (void)mobfoxNativeFormatActionWillFinish {
    [self reportViewActionWillFinish];
}

@end
