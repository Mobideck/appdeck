//
//  FacebookCustomEventNative.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 04.07.2014.
//
//

#import "FacebookCustomEventNative.h"

@implementation FacebookCustomEventNative

-(void)loadNativeAdWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel {
    [self addImpressionTrackerWithUrl:trackingPixel];
    
    Class facebookNativeClass = NSClassFromString(@"FBNativeAd");
    if (!facebookNativeClass) {
        [self.delegate customEventNativeFailed];
        return;
    }
    
    [self performSelectorOnMainThread:@selector(loadFacebook:) withObject:optionalParameters waitUntilDone:YES];

}

- (void) loadFacebook:(NSString *)key {
    Class facebookNativeClass = NSClassFromString(@"FBNativeAd");
    facebookNativeAd = [[facebookNativeClass alloc] initWithPlacementID:key];
    facebookNativeAd.delegate = self;
    [facebookNativeAd loadAd];
}

-(void)dealloc {
    [facebookNativeAd unregisterView];
    facebookNativeAd = nil;
}

-(void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    [self.delegate customEventNativeFailed];
}

-(void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    
    facebookNativeAd = nativeAd;
    
    [self addTextAsset:nativeAd.title withType:kHeadlineTextAsset];
    [self addTextAsset:nativeAd.body withType:kDescriptionTextAsset];
    [self addTextAsset:nativeAd.callToAction withType:kCallToActionTextAsset];
    [self addTextAsset:nativeAd.socialContext withType:@"socialContextForAd"];
    
    if (nativeAd.starRating.scale != 0) {
        NSNumber* stars = [NSNumber numberWithFloat:5*nativeAd.starRating.value/nativeAd.starRating.scale];
        [self addTextAsset:[stars stringValue] withType:kRatingTextAsset];
    }
    
    [self addImageAssetWithImageUrl:[nativeAd.icon.url absoluteString] andType:kIconImageAsset];
    [self addImageAssetWithImageUrl:[nativeAd.coverImage.url absoluteString] andType:kMainImageAsset];
    
    
    if([self isNativeAdValid]) {
        [self.delegate customEventNativeLoaded:self];
    } else {
        [self.delegate customEventNativeFailed];
    }
}

-(void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd {
}

-(void)nativeAdDidClick:(FBNativeAd *)nativeAd {
    
}

-(void)prepareImpressionWithView:(UIView *)view andViewController:(UIViewController *)viewController  {
    [facebookNativeAd registerViewForInteraction:view withViewController:viewController];
}

@end
