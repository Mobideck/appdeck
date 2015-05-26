//
//  MPLegacyBannerCustomEventAdapter.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPLegacyBannerCustomEventAdapterMF.h"
#import "MPAdConfigurationMF.h"
#import "MpLoggingMF.h"

@implementation MPLegacyBannerCustomEventAdapterMF

- (void)getAdWithConfiguration:(MPAdConfigurationMF *)configuration containerSize:(CGSize)size
{
    MPLogInfoMF(@"Looking for custom event selector named %@.", configuration.customSelectorName);

    SEL customEventSelector = NSSelectorFromString(configuration.customSelectorName);
    if ([self.delegate.bannerDelegate respondsToSelector:customEventSelector]) {
        [self.delegate.bannerDelegate performSelector:customEventSelector];
        return;
    }

    NSString *oneArgumentSelectorName = [configuration.customSelectorName
                                         stringByAppendingString:@":"];

    MPLogInfoMF(@"Looking for custom event selector named %@.", oneArgumentSelectorName);

    SEL customEventOneArgumentSelector = NSSelectorFromString(oneArgumentSelectorName);
    if ([self.delegate.bannerDelegate respondsToSelector:customEventOneArgumentSelector]) {
        [self.delegate.bannerDelegate performSelector:customEventOneArgumentSelector
                                           withObject:self.delegate.banner];
        return;
    }

    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)startTimeoutTimer
{
    // Override to do nothing as we don't want to time out these legacy custom events.
}

@end
