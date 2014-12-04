//
//  MPNativeAdPageView.m
//  MoPubSampleApp
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeAdPageView.h"

@implementation MPNativeAdPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, 212, 60)];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [self.titleLabel setText:@"Title"];
        [self addSubview:self.titleLabel];

        self.mainTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 75, 300, 26)];
        [self.mainTextLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.mainTextLabel setText:@"Text"];
        [self addSubview:self.mainTextLabel];

        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        [self addSubview:self.iconImageView];

        self.mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 109, 300, 156)];
        [self.mainImageView setClipsToBounds:YES];
        [self.mainImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:self.mainImageView];

        self.ctaLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 265, 300, 48)];
        [self.ctaLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.ctaLabel setText:@"CTA Text"];
        [self.ctaLabel setTextColor:[UIColor greenColor]];
        [self.ctaLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:self.ctaLabel];

        self.backgroundColor = [UIColor colorWithWhite:0.21 alpha:1.0f];
        self.titleLabel.textColor = [UIColor colorWithWhite:0.86 alpha:1.0f];
        self.mainTextLabel.textColor = [UIColor colorWithWhite:0.86 alpha:1.0f];

        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.mainTextLabel.backgroundColor = [UIColor clearColor];
        self.ctaLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - <MPNativeAdRendering>

- (void)layoutAdAssets:(MPNativeAd *)adObject
{
    [adObject loadTitleIntoLabel:self.titleLabel];
    [adObject loadTextIntoLabel:self.mainTextLabel];
    [adObject loadIconIntoImageView:self.iconImageView];
    [adObject loadImageIntoImageView:self.mainImageView];
    [adObject loadCallToActionTextIntoLabel:self.ctaLabel];
}

+ (CGSize)sizeWithMaximumWidth:(CGFloat)maximumWidth
{
    return CGSizeMake(320, 480);
}

@end
