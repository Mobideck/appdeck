//
//  MPNativeCollectionViewAdCollectionViewCell.h
//  MoPubSampleApp
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPNativeAdRendering.h"


@interface MPNativeCollectionViewAdCollectionViewCell : UICollectionViewCell <MPNativeAdRendering>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIImageView *DAAIconImageView;
@property (strong, nonatomic) UILabel *ctaLabel;

@end
