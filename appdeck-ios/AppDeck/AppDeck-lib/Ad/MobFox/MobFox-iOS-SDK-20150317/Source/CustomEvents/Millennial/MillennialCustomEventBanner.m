//
//  MillennialCustomEventBanner.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 18.06.2014.
//
//

#import "MillennialCustomEventBanner.h"

@interface MillennialCustomEventBanner()
@property (nonatomic, strong) MMAdView* adView;
@end

@implementation MillennialCustomEventBanner

- (void)loadBannerWithSize:(CGSize)size optionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    
    Class bannerClass = NSClassFromString(@"MMAdView");
    Class requestClass = NSClassFromString(@"MMRequest");
    if(!requestClass || !bannerClass) {
        [self.delegate customEventBannerDidFailToLoadAd];
        return;
    }
    
    self.adView = [[bannerClass alloc] initWithFrame:CGRectMake(0,0,size.width, size.height) apid:optionalParameters rootViewController:[self.delegate viewControllerForPresentingModalView]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adModalWillAppear:)
                                                 name:@"MillennialMediaAdModalWillAppear"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adModalWillDismiss:)
                                                 name:@"MillennialMediaAdModalWillDismiss"
                                               object:nil];
    
    MMRequest *request = [requestClass request];
    
    [self.adView getAdWithRequest:request onCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self didDisplayAd];
            [self.delegate customEventBannerDidLoadAd:self.adView];
        }
        else {
            [self.delegate customEventBannerDidFailToLoadAd];
        }
    }];
    
}

- (void)adModalWillAppear:(NSNotification *)notification {
     [self.delegate customEventBannerWillExpand];
}

- (void)adModalWillDismiss:(NSNotification *)notification {
    [self.delegate customEventBannerWillClose];
}

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.adView = nil;
}

@end
