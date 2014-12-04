//
//  FBNativeAd+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FBNativeAd+Specs.h"

static BOOL gUserZeroScaleInStarRating;
static BOOL gUseNilForCoverImage;
static BOOL gUseNilForIconImage;

@implementation FBNativeAd (Specs)

+ (void)useZeroScaleInStarRating:(BOOL)useZero
{
    gUserZeroScaleInStarRating = useZero;
}

+ (void)useNilForCoverImage:(BOOL)useNil
{
    gUseNilForCoverImage = useNil;
}

+ (void)useNilForIconImage:(BOOL)useNil
{
    gUseNilForIconImage = useNil;
}

- (void)loadAd
{
    [self.delegate nativeAdDidLoad:self];
}

- (FBAdImage *)coverImage
{
    if (gUseNilForCoverImage) {
        return nil;
    }

    return [[FBAdImage alloc] initWithURL:[NSURL URLWithString:@"https://pbs.twimg.com/profile_images/431949550836662272/A6Ck-0Gx_normal.png"] width:50 height:50];
}

- (FBAdImage *)icon
{
    if (gUseNilForIconImage) {
        return nil;
    }

    return [[FBAdImage alloc] initWithURL:[NSURL URLWithString:@"https://pbs.twimg.com/profile_images/431949550836662272/A6Ck-0Gx_normal.png"] width:50 height:50];
}

- (struct FBAdStarRating)starRating
{
    if (gUserZeroScaleInStarRating) {
        return (struct FBAdStarRating){2.0f,0};
    } else {
        return (struct FBAdStarRating){2.0f,10};
    }
}

@end
