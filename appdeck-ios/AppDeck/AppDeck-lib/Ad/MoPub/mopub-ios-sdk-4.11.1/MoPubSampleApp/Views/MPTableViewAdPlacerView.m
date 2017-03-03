//
//  MPTableViewAdPlacerView.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPTableViewAdPlacerView.h"
#import "MPNativeAdRenderingImageLoader.h"

@implementation MPTableViewAdPlacerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [self.titleLabel setText:@"Title"];
        [self addSubview:self.titleLabel];

        self.mainTextLabel = [[UILabel alloc] init];
        [self.mainTextLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.mainTextLabel setText:@"Text"];
        [self.mainTextLabel setNumberOfLines:2];
        [self addSubview:self.mainTextLabel];

        self.iconImageView = [[UIImageView alloc] init];
        [self addSubview:self.iconImageView];

        self.mainImageView = [[UIImageView alloc] init];
        [self.mainImageView setClipsToBounds:YES];
        [self.mainImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:self.mainImageView];

        self.ctaLabel = [[UILabel alloc] init];
        [self.ctaLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.ctaLabel setText:@"CTA Text"];
        [self.ctaLabel setTextColor:[UIColor greenColor]];
        [self.ctaLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:self.ctaLabel];

        self.privacyInformationIconImageView = [[UIImageView alloc] init];
        [self addSubview:self.privacyInformationIconImageView];

        self.backgroundColor = [UIColor colorWithWhite:0.21 alpha:1.0f];
        self.titleLabel.textColor = [UIColor colorWithWhite:0.86 alpha:1.0f];
        self.mainTextLabel.textColor = [UIColor colorWithWhite:0.86 alpha:1.0f];

        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat width = self.bounds.size.width;

    self.titleLabel.frame = CGRectMake(75, 10, 212, 60);
    self.iconImageView.frame = CGRectMake(10, 10, 60, 60);
    self.privacyInformationIconImageView.frame = CGRectMake(width - 30, 10, 20, 20);
    self.ctaLabel.frame = CGRectMake(width - 100, 270, 90, 48);
    self.mainTextLabel.frame = CGRectMake(width / 2 - 150, 68, 300, 50);
    self.mainImageView.frame = CGRectMake(width / 2 - 150, 119, 300, 156);
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

- (UIImageView *)nativePrivacyInformationIconImageView
{
    return self.privacyInformationIconImageView;
}

// This is where you can construct and layout your view that represents your star rating.
/*
- (void)layoutStarRating:(NSNumber *)starRating
{

}
*/

// This is where you can place custom assets from the properties dictionary in your view.
// The code below shows how a custom image can be loaded.
/*
- (void)layoutCustomAssetsWithProperties:(NSDictionary *)customProperties imageLoader:(MPNativeAdRenderingImageLoader *)imageLoader
{
    [imageLoader loadImageForURL:[NSURL URLWithString:customProperties[@"wutImage"]] intoImageView:self.customImageView];
}
*/

@end
