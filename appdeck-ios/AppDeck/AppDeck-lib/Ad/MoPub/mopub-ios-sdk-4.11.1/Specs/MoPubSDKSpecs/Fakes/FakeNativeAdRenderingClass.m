//
//  FakeNativeAdRenderingClass.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "FakeNativeAdRenderingClass.h"

@implementation FakeNativeAdRenderingClass

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.privacyInformationIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self addSubview:self.privacyInformationIconImageView];

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

        self.ctaLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 270, 300, 48)];
        [self.ctaLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.ctaLabel setText:@"CTA Text"];
        [self.ctaLabel setTextColor:[UIColor greenColor]];
        [self.ctaLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:self.ctaLabel];

        self.backgroundColor = [UIColor colorWithWhite:0.21 alpha:1.0f];
        self.titleLabel.textColor = [UIColor colorWithWhite:0.86 alpha:1.0f];
        self.mainTextLabel.textColor = [UIColor colorWithWhite:0.86 alpha:1.0f];

        self.clipsToBounds = YES;

        _didLayoutStarRating = NO;
    }
    return self;
}

- (UILabel *)nativeMainTextLabel
{
    return self.mainTextLabel;
}

- (UILabel *)nativeTitleTextLabel
{
    return self.titleLabel;
}

- (UILabel *)nativeCtaTextLabel
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

- (UIImageView *)nativePrivacyInformationIconImageView
{
    return self.privacyInformationIconImageView;
}

- (void)layoutStarRating:(NSNumber *)starRating
{
    self.didLayoutStarRating = YES;
    self.lastStarRating = starRating;
}

- (void)layoutCustomAssetsWithProperties:(NSDictionary *)customProperties imageLoader:(MPNativeAdRenderingImageLoader *)imageLoader
{

}
@end
