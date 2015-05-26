//
//  CustomEventNative.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 01.07.2014.
//
//

#import "MFCustomEventNative.h"

@implementation MFCustomEventNative

@synthesize delegate;

-(void)loadNativeAdWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel {
    //Subclasses must override this method.
}

-(void)addImageAssetWithImageUrl:(NSString*)url andType:(NSString*)type {
    if(url && type) {
        MFImageAsset* asset = [[MFImageAsset alloc]initWithUrl:url width:0 height:0];
        [self addImageAsset:asset withType:type];
    }
}

-(void)addImpressionTrackerWithUrl:(NSString*)url {
    if(url && url.length > 0) {
        MFTracker* tracker = [[MFTracker alloc]init];
        tracker.type = kImpressionTrackerType;
        tracker.url = url;
        [self.trackers addObject:tracker];
    }
}

-(void)addExtraAsset:(NSString*)asset withType:(NSString*)type {
    if([type rangeOfString:@"image" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        [self addImageAssetWithImageUrl:asset andType:type];
    } else {
        [self addTextAsset:asset withType:type];
    }
}

-(void)destroy {
    delegate = nil;
}

-(void)dealloc {
    [self destroy];
}

@end
