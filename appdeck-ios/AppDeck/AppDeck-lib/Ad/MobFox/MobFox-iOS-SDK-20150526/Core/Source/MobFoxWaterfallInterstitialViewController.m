//
//  MobFoxWaterfallInterstitialViewController.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 05.05.2015.
//
//

#import "MobFoxWaterfallInterstitialViewController.h"
#import "MobFoxCreativesQueueManager.h"
#import "MobFoxNativeFormatCreativesManager.h"
#import "MobFoxNativeFormatView.h"
#import "MobFoxVideoInterstitialViewController.h"
#import "MobFoxInterstitialPlayerViewController.h"
#import "MobFoxNativeFormatInterstitial.h"
#import "UIImage+MobFox.h"

@interface MobFoxWaterfallInterstitialViewController () <MobFoxVideoInterstitialViewControllerDelegate, MobFoxNativeFormatInterstitialDelegate> {
}

@property (nonatomic, strong) MobFoxCreativesQueueManager* queueManager;
@property (nonatomic, strong) NSMutableArray* adQueue;

@property (nonatomic, strong) MobFoxVideoInterstitialViewController *videoInterstitialViewController;
@property (nonatomic, strong) MobFoxNativeFormatInterstitial *nativeInterstitial;

@property (nonatomic, assign) MobFoxCreativeType loadedCreativeType;
@property (nonatomic, assign) BOOL advertRequestInProgress;
@property (nonatomic, strong) UIViewController* viewController;

@end


@implementation MobFoxWaterfallInterstitialViewController


@synthesize videoInterstitialViewController;

-(instancetype)initWithViewController:(UIViewController *)controller {
    self = [super init];
    self.viewController = controller;
    [self setup];
    return self;
}


- (void)setup {
    
    self.videoInterstitialViewController = [[MobFoxVideoInterstitialViewController alloc] init];
    self.videoInterstitialViewController.delegate = self;
    
    [self.viewController.view addSubview:self.videoInterstitialViewController.view];
}

-(void)setDelegate:(id<MobFoxWaterfallInterstitialDelegate>)delegate {
    _delegate = delegate;
    self.queueManager = [MobFoxCreativesQueueManager sharedManagerWithPublisherId:[self.delegate publisherIdForMobFoxWaterfallInterstitial]];
    self.nativeInterstitial = [[MobFoxNativeFormatInterstitial alloc]initWithPublisherId:[delegate publisherIdForMobFoxWaterfallInterstitial]];
    self.nativeInterstitial.delegate = self;
}

-(void)requestAd {
    if (self.advertRequestInProgress) {
        return;
    }
    [self requestAdInternal];
}

-(void) requestAdInternal {
    if (!self.delegate)
    {
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Delegate for waterfall interstitial not set!" forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorInventoryUnavailable userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        
        return;
    }
    
    self.loadedCreativeType = 0;
    self.advertRequestInProgress = YES;
    
    if(!self.adQueue) {
        self.adQueue = [self.queueManager getCreativesQueueForFullscreen];
    }
    if (self.adQueue.count < 1) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No ad types in queue!" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        return;
    }
    
    
    MobFoxCreative* chosenCreative = [self.queueManager getCreativeFromQueue:self.adQueue];
    
    switch (chosenCreative.type) {
        case MobFoxCreativeBanner: {
            [self requestStaticInterstitial];
            break;
        }
            
        case MobFoxCreativeNativeFormat: {
            [self requestNativeFormatInterstitial];
            break;
        }
            
        case MobFoxCreativeVideo: {
            [self requestVideo];
            break;
        }
            
        default: {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Chosen creative type not supported for interstitials!" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(interstitialFailedWithError:) withObject:error waitUntilDone:YES];
        }
    }

}

-(void)dealloc {
    self.delegate = nil;
    [self.videoInterstitialViewController removeFromParentViewController];
    self.videoInterstitialViewController.delegate = nil;
    self.nativeInterstitial.delegate = nil;
    self.nativeInterstitial = nil;
    self.videoInterstitialViewController = nil;
    self.viewController = nil;
}

- (void) requestStaticInterstitial {
    self.videoInterstitialViewController.requestURL = @"http://my.mobfox.com/request.php";
    self.videoInterstitialViewController.enableInterstitialAds = YES;
    self.videoInterstitialViewController.enableVideoAds = NO;
    [self.videoInterstitialViewController requestAd];
}

- (void) requestVideo {
    self.videoInterstitialViewController.requestURL = @"http://my.mobfox.com/request.php";
    self.videoInterstitialViewController.enableVideoAds = YES;
    self.videoInterstitialViewController.prioritizeVideoAds = YES;
    self.videoInterstitialViewController.enableInterstitialAds = NO;
    [self.videoInterstitialViewController requestAd];
}

- (void) requestNativeFormatInterstitial {
    [self.nativeInterstitial requestAdWithPublisherId:[self.delegate publisherIdForMobFoxWaterfallInterstitial] andViewController:self.viewController];
}

- (void) showAd {
    switch (self.loadedCreativeType) {
        case MobFoxCreativeBanner: {
            [self.videoInterstitialViewController presentAd:MobFoxAdTypeText];
            break;
        }
            
        case MobFoxCreativeNativeFormat: {
            [self.nativeInterstitial showAd];
            break;
        }
            
        case MobFoxCreativeVideo: {
            [self.videoInterstitialViewController presentAd:MobFoxAdTypeVideo];
            break;
        }
            
        default: {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Cannot display interstitial, as it is not properly loaded." forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self.delegate mobfoxWaterfallDidFailToLoadWithError:error];
        }
    }

}

- (void) reportAdLoaded {
    self.adQueue = nil;
    self.advertRequestInProgress = NO;
    [self.delegate mobfoxWaterfallInterstitialDidLoad];
}

- (void)interstitialFailedWithError:(NSError *)error
{

    if(self.adQueue.count > 0) {
        [self requestAdInternal];
    } else {
        self.adQueue = nil;
        self.advertRequestInProgress = NO;
        [self.delegate mobfoxWaterfallDidFailToLoadWithError:error];
    }
}


#pragma mark Native Format Interstitial delegate methods
- (void)mobfoxNativeFormatInterstitialDidLoad {
    self.loadedCreativeType = MobFoxCreativeNativeFormat;
    [self reportAdLoaded];
}

- (void)mobfoxNativeFormatInterstitialDidFailToLoadWithError:(NSError *)error {
    [self interstitialFailedWithError:error];
}

- (void)mobfoxNativeFormatInterstitialWillPresent {
    if ([self.delegate respondsToSelector:@selector(mobfoxWaterfallInterstitialWillPresent)])
    {
        [self.delegate mobfoxWaterfallInterstitialWillPresent];
    }
}

- (void)mobfoxNativeFormatInterstitialActionWillFinish {
    if ([self.delegate respondsToSelector:@selector(mobfoxWaterfallInterstitialActionWillFinish)])
    {
        [self.delegate mobfoxWaterfallInterstitialActionWillFinish];
    }
}

#pragma mark VideoInterstitialViewController delegate methods
- (NSString *)publisherIdForMobFoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial {
    return [self.delegate publisherIdForMobFoxWaterfallInterstitial];
}

- (void)mobfoxVideoInterstitialViewDidLoadMobFoxAd:(MobFoxVideoInterstitialViewController *)videoInterstitial advertTypeLoaded:(MobFoxAdType)advertType {
    if (advertType == MobFoxAdTypeVideo) {
        self.loadedCreativeType = MobFoxCreativeVideo;
    } else {
        self.loadedCreativeType = MobFoxCreativeBanner;
    }
    
    [self reportAdLoaded];
}

- (void)mobfoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial didFailToReceiveAdWithError:(NSError *)error {
    [self interstitialFailedWithError:error];
}

- (void)mobfoxVideoInterstitialViewActionWillPresentScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial {
    if ([self.delegate respondsToSelector:@selector(mobfoxWaterfallInterstitialWillPresent)])
    {
        [self.delegate mobfoxWaterfallInterstitialWillPresent];
    }
}

- (void)mobfoxVideoInterstitialViewWillDismissScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial {
    if ([self.delegate respondsToSelector:@selector(mobfoxWaterfallInterstitialActionWillFinish)])
    {
        [self.delegate mobfoxWaterfallInterstitialActionWillFinish];
    }
}

@end
