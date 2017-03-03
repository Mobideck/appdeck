//
//  FakeNativeAdRenderingClass.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPNativeAdRendering.h"

@interface FakeNativeAdRenderingClass : UIView <MPNativeAdRendering>

@property (nonatomic, strong) UILabel *ctaLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *mainTextLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIImageView *privacyInformationIconImageView;

@property (nonatomic, assign) BOOL didLayoutStarRating;
@property (nonatomic, strong) NSNumber *lastStarRating;

@end
