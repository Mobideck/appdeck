//
//  MPCollectionViewAdPlacerView.h
//  MoPubSampleApp
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPNativeAdRendering.h"


@interface MPCollectionViewAdPlacerView : UIView <MPNativeAdRendering>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *ctaLabel;
@property (strong, nonatomic) UIImageView *privacyInformationIconImageView;

@end
