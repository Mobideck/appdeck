//
//  MPNativeAdView.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeAdView.h"

@implementation MPNativeAdView

- (void)clearAd
{
    self.titleLabel.text = @"Title Label";
    self.bodyLabel.text = @"Ad Body Label";
    self.ctaLabel.text = @"Call To Action Label";
    
    self.iconImageView.image = nil;
    self.fullsizeImageView.image = nil;
}

- (void)layoutAdAssets:(MPNativeAd *)adObject
{
    [adObject loadIconIntoImageView:self.iconImageView];
    [adObject loadImageIntoImageView:self.fullsizeImageView];
    
    [adObject loadTitleIntoLabel:self.titleLabel];
    [adObject loadTextIntoLabel:self.bodyLabel];
    [adObject loadCallToActionTextIntoLabel:self.ctaLabel];
}


@end
