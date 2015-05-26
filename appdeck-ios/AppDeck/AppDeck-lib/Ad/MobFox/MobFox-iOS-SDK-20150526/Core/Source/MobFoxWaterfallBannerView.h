//
//  MobFoxWaterfallBannerView.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 04.05.2015.
//
//

#import <UIKit/UIKit.h>

@class MobFoxWaterfallBannerView;

@protocol MobFoxWaterfallBannerViewDelegate <NSObject>

- (NSString *)publisherIdForMobFoxWaterfallBannerView:(MobFoxWaterfallBannerView *)banner;

@optional

- (void)mobfoxWaterfallBannerViewDidLoadMobFoxAd:(MobFoxWaterfallBannerView *)banner;

- (void)mobfoxWaterfallBannerViewDidFailToReceiveAdWithError:(NSError *)error;

- (void)mobfoxWaterfallBannerViewActionWillPresent;

- (void)mobfoxWaterfallBannerViewActionWillFinish;


@end

@interface MobFoxWaterfallBannerView : UIView

@property (nonatomic, assign) IBOutlet __unsafe_unretained id <MobFoxWaterfallBannerViewDelegate> delegate;

@property (nonatomic, assign) NSInteger adspaceWidth;
@property (nonatomic, assign) NSInteger adspaceHeight;

- (void)requestAd;

@end
