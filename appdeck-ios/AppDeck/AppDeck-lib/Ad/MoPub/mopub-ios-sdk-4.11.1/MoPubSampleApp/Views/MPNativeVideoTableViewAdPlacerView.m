//
//  MPNativeVideoTableViewAdPlacerView.m
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPNativeVideoTableViewAdPlacerView.h"
#import "MPGlobal.h"

@implementation MPNativeVideoTableViewAdPlacerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, 212, 60)];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [self.titleLabel setText:@"Title"];
        [self addSubview:self.titleLabel];

        self.mainTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 68, 300, 50)];
        [self.mainTextLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.mainTextLabel setText:@"Text"];
        [self.mainTextLabel setNumberOfLines:2];
        [self addSubview:self.mainTextLabel];

        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        [self addSubview:self.iconImageView];

        self.mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 119, 300, 156)];
        [self.mainImageView setClipsToBounds:YES];
        [self.mainImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:self.mainImageView];

        self.videoView = [[UIView alloc] initWithFrame:CGRectMake(10, 119, 300, 156)];
        self.videoView.clipsToBounds = YES;
        [self.videoView setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:self.videoView];

        self.ctaLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 270, 300, 48)];
        [self.ctaLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.ctaLabel setText:@"CTA Text"];
        [self.ctaLabel setTextColor:[UIColor greenColor]];
        [self.ctaLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:self.ctaLabel];

        self.DAAIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 10, 20, 20)];
        [self addSubview:self.DAAIconImageView];

        self.backgroundColor = [UIColor colorWithWhite:0.21 alpha:1.0f];
        self.titleLabel.textColor = [UIColor colorWithWhite:0.86 alpha:1.0f];
        self.mainTextLabel.textColor = [UIColor colorWithWhite:0.86 alpha:1.0f];

        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    if (UIInterfaceOrientationIsLandscape(MPInterfaceOrientation())) {
        self.titleLabel.frame = CGRectMake(200, 10, 212, 60);
        self.videoView.frame = CGRectMake(0, 119, 320, 156);
    } else {
        self.titleLabel.frame = CGRectMake(75, 10, 212, 60);
        self.videoView.frame = CGRectMake(10, 119, 300, 156);
    }
}

#pragma mark - <MPNativeAdRendering>

- (UILabel *)nativeMainTextLabel
{
    return self.mainTextLabel;
}

- (UILabel *)nativeTitleTextLabel
{
    return self.titleLabel;
}

- (UILabel *)nativeCallToActionTextLabel
{
    return self.ctaLabel;
}

- (UIImageView *)nativeIconImageView
{
    return self.iconImageView;
}

- (UIImageView *)nativeMainImageView
{
    return self.mainImageView;
}

- (UIView *)nativeVideoView
{
    return self.videoView;
}

- (UIImageView *)nativePrivacyInformationIconImageView
{
    return self.DAAIconImageView;
}

@end
