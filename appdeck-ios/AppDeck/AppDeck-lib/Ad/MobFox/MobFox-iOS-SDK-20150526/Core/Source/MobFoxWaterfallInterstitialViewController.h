//
//  MobFoxWaterfallInterstitialViewController.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 05.05.2015.
//
//

#import <UIKit/UIKit.h>

@protocol MobFoxWaterfallInterstitialDelegate <NSObject>

- (NSString*)publisherIdForMobFoxWaterfallInterstitial;

@optional

- (void)mobfoxWaterfallInterstitialDidLoad;

- (void)mobfoxWaterfallDidFailToLoadWithError:(NSError *)error;

- (void)mobfoxWaterfallInterstitialWillPresent;

- (void)mobfoxWaterfallInterstitialActionWillFinish;

@end

@interface MobFoxWaterfallInterstitialViewController : NSObject

@property (nonatomic, assign) IBOutlet __unsafe_unretained id <MobFoxWaterfallInterstitialDelegate> delegate;

- (instancetype)initWithViewController:(UIViewController*)controller;

- (void) requestAd;

- (void) showAd;

@end
