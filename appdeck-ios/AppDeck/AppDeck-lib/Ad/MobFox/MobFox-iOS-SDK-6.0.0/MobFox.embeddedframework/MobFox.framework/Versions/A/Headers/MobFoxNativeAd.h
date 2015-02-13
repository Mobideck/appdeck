//
//  NativeAd.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 21.05.2014.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ImageAsset;
@class Tracker;
@class UIImage;

@interface MobFoxNativeAd : NSObject
extern NSString * const kIconImageAsset;
extern NSString * const kMainImageAsset;
extern NSString * const kHeadlineTextAsset;
extern NSString * const kDescriptionTextAsset;
extern NSString * const kCallToActionTextAsset;
extern NSString * const kAdvertiserTextAsset;
extern NSString * const kRatingTextAsset;
extern NSString * const kImpressionTrackerType;

@property (nonatomic, strong) NSString* clickUrl;
@property (nonatomic, strong) NSMutableDictionary* imageAssets;
@property (nonatomic, strong) NSMutableDictionary* textAssets;
@property (nonatomic, strong) NSMutableArray *customEvents;
@property (nonatomic, strong) NSMutableArray* trackers;

-(void)addTextAsset:(NSString*)text withType:(NSString*)type;
-(void)addImageAsset:(ImageAsset*)asset withType:(NSString*)type;
-(BOOL)isNativeAdValid;

-(void)handleImpression;
-(void)handleClick;
-(void)prepareImpressionWithView:(UIView *)view andViewController:(UIViewController*)viewController;

@end

@interface ImageAsset : NSObject
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) NSString* width;
@property (nonatomic, strong) NSString* height;

-(id)initWithUrl:(NSString*)url width:(NSString*)width height:(NSString*)height;

@end

@interface Tracker : NSObject
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* url;
@end