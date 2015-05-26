//
//  MobFoxNativeFormatInterstitial.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 05.05.2015.
//
//

#import <UIKit/UIKit.h>

@protocol MobFoxNativeFormatInterstitialDelegate <NSObject>

- (void)mobfoxNativeFormatInterstitialDidLoad;

- (void)mobfoxNativeFormatInterstitialDidFailToLoadWithError:(NSError *)error;

- (void)mobfoxNativeFormatInterstitialWillPresent;

- (void)mobfoxNativeFormatInterstitialActionWillFinish;

@end

@interface MobFoxNativeFormatInterstitial : NSObject

@property (nonatomic, assign) IBOutlet __unsafe_unretained id <MobFoxNativeFormatInterstitialDelegate> delegate;

-(instancetype)initWithPublisherId:(NSString*)publisherId;

-(void) requestAdWithPublisherId:(NSString *)publisherId andViewController:(UIViewController*)controller;

-(void) showAd;

@end
