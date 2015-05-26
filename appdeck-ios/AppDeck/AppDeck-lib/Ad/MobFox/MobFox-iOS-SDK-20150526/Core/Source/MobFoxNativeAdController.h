//
//  MobFoxNativeAdController.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 21.05.2014.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MobFoxNativeAdController;
@class MobFoxNativeAd;

@protocol MobFoxNativeAdDelegate <NSObject>

- (NSString *)publisherIdForMobFoxNativeAdController:(MobFoxNativeAdController *)controller;

- (void) nativeAdDidLoad:(MobFoxNativeAd *)ad;

- (void) nativeAdFailedToLoadWithError:(NSError *)error;

- (void) nativeAdWasShown;

- (void) nativeAdWasClicked;

- (UIViewController*) viewControllerForNativeAds;

@end

@interface MobFoxNativeAdController : NSObject

@property (strong, nonatomic) NSString *requestURL;
@property (nonatomic, assign) IBOutlet __unsafe_unretained id <MobFoxNativeAdDelegate> delegate;
@property (nonatomic, assign) BOOL locationAwareAdverts;
@property (nonatomic, assign) NSInteger userAge;
@property (nonatomic, strong) NSString* userGender;
@property (nonatomic, strong) NSArray* keywords;

@property (nonatomic, strong) NSArray* adTypes;

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude;

- (UIView*)getNativeAdViewForResponse:(MobFoxNativeAd*)response xibName:(NSString*)name;

- (void)requestAd;

@end
