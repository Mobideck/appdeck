//
//  MPNativeVideoTableViewAdPlacerView.h

#import "MPNativeAdRendering.h"

@interface MPNativeVideoTableViewAdPlacerView : UIView <MPNativeAdRendering>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *mainTextLabel;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIView *videoView;
@property (strong, nonatomic) UIImageView *DAAIconImageView;
@property (strong, nonatomic) UILabel *ctaLabel;

@end
