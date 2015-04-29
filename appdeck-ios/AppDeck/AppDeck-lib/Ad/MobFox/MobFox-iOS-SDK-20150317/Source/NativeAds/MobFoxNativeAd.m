//
//  NativeAd.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 21.05.2014.
//
//

#import "MobFoxNativeAd.h"
#import <UIKit/UIKit.h>

NSString * const kIconImageAsset = @"icon";
NSString * const kMainImageAsset = @"main";
NSString * const kHeadlineTextAsset = @"headline";
NSString * const kDescriptionTextAsset = @"description";
NSString * const kCallToActionTextAsset = @"cta";
NSString * const kAdvertiserTextAsset = @"advertiser";
NSString * const kRatingTextAsset = @"rating";
NSString * const kImpressionTrackerType = @"impression";

@implementation MobFoxNativeAd

- (id)init {
    self = [super init];
    self.imageAssets = [[NSMutableDictionary alloc] init];
    self.textAssets = [[NSMutableDictionary alloc] init];
    self.trackers = [[NSMutableArray alloc] init];
    self.customEvents = [[NSMutableArray alloc] init];
    
    return self;
}

-(void)handleClick {
    //custom events may implement this method
}
-(void)handleImpression {
    //custom events may implement this method    
}

-(void)prepareImpressionWithView:(UIView *)view andViewController:(UIViewController*)viewController{
    //custom events may implement this method        
}

-(void)addImageAsset:(ImageAsset *)asset withType:(NSString *)type {
    if(asset && type) {
        [self.imageAssets setObject:asset forKey:type];
    }
}

-(void)addTextAsset:(NSString *)text withType:(NSString *)type {
    if(text && type) {
        [self.textAssets setObject:text forKey:type];
    }
}

-(BOOL)isNativeAdValid {
    BOOL textAssetsOK = NO;
    BOOL imageAssetsOK = NO;
    
    ImageAsset* iconImageAsset = [self.imageAssets objectForKey:kIconImageAsset];
    ImageAsset* mainImageAsset = [self.imageAssets objectForKey:kMainImageAsset];
    
    if(mainImageAsset && iconImageAsset && mainImageAsset.image && iconImageAsset.image) {
        imageAssetsOK = YES;
    }
    
    if([self.textAssets objectForKey:kHeadlineTextAsset] && [self.textAssets objectForKey:kDescriptionTextAsset] &&
       [[self.textAssets objectForKey:kHeadlineTextAsset]length] > 0 && [[self.textAssets objectForKey:kDescriptionTextAsset]length] > 0) {
        textAssetsOK = YES;
    }
    
    return (textAssetsOK && imageAssetsOK);
}

@end

@implementation ImageAsset

-(id)initWithUrl:(NSString*)url width:(NSString*)width height:(NSString*)height {
    self = [super init];
    self.width = width;
    self.height = height;
    self.url = url;
    self.image = [self downloadImageFromUrl:url];
    
    return self;
}

-(UIImage*)downloadImageFromUrl:(NSString*)url {
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    result = [UIImage imageWithData:data];
    
    return result;
}

@end

@implementation Tracker
@end