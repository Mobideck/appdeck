//
//  FBAdView+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "FBAdView+Specs.h"

static BOOL disabledAutoRefresh;
static FBAdSize fbAdSize;

@implementation FBAdView (Specs)

- (void)dealloc
{
    [FBAdView resetAutoRefreshWasDisabledValue];
}

- (instancetype)initWithPlacementID:(NSString *)placementID adSize:(FBAdSize)adSize rootViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        fbAdSize = adSize;
    }
    return self;
}

- (void)loadAd
{
    /*
     * Overidding default behavior because by default, calling this method in
     * Specs crashes the Facebook Audience Network SDK. Since our test behavior
     * doesn't need a live ad, the override can safely do nothing.
     */
}

- (void)disableAutoRefresh
{
    disabledAutoRefresh = YES;
}

- (FBAdSize)fbAdSize
{
    return fbAdSize;
}

+ (BOOL)autoRefreshWasDisabled
{
    return disabledAutoRefresh;
}

+ (void)resetAutoRefreshWasDisabledValue
{
    disabledAutoRefresh = NO;
}

@end
