//
//  MoPubCustomEventNative.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 02.07.2014.
//
//

#import "MoPubCustomEventNative.h"
#import "MPNativeAdConstantsMF.h"

@interface MoPubCustomEventNative()
@property (nonatomic, strong) MPNativeAdMF* moPubNativeAd;
@end

@implementation MoPubCustomEventNative

-(void)loadNativeAdWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel {
    [self addImpressionTrackerWithUrl:trackingPixel];
    MPNativeAdRequestMF *adRequest = [MPNativeAdRequestMF requestWithAdUnitIdentifier:optionalParameters];

    [self performSelectorOnMainThread:@selector(loadMoPub:) withObject:adRequest waitUntilDone:YES];
    
}

- (void) loadMoPub:(MPNativeAdRequestMF *)adRequest {
    [adRequest startWithCompletionHandler:^(MPNativeAdRequestMF *request, MPNativeAdMF *response, NSError *error) {
        if (error) {
            [self.delegate customEventNativeFailed];
        } else {
            self.moPubNativeAd = response;
            [self setClickUrl:[response.defaultActionURL absoluteString]];
            
            [self addTextAsset:[response.properties objectForKey:kAdCTATextKeyMF] withType:kCallToActionTextAsset];
            [self addTextAsset:[response.properties objectForKey:kAdTitleKeyMF] withType:kHeadlineTextAsset];
            [self addTextAsset:[response.properties objectForKey:kAdTextKeyMF] withType:kDescriptionTextAsset];
            
            NSNumber *starRatingNum = response.starRating;
            if(starRatingNum) {
                NSString* starRating = [starRatingNum stringValue];
                [self addTextAsset:starRating withType:kRatingTextAsset];
            }

            [self addImageAssetWithImageUrl:[response.properties objectForKey:kAdIconImageKeyMF] andType:kIconImageAsset];
            [self addImageAssetWithImageUrl:[response.properties objectForKey:kAdMainImageKeyMF] andType:kMainImageAsset];

            
            if([self isNativeAdValid]) {
                [self.delegate customEventNativeLoaded:self];
            } else {
                [self.delegate customEventNativeFailed];
            }
        }
    }];

    
}

-(void)handleClick {
    [self.moPubNativeAd trackClick];
}

-(void)handleImpression {
    [self.moPubNativeAd trackImpression];
}



@end
