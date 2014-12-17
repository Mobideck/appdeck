//
//  WideSpaceBannerAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "WideSpaceAdViewController.h"
#import "WideSpaceAdEngine.h"
#import "../../LoaderChildViewController.h"
#import "../../AppDeck.h"
#import "../../AppDeckUserProfile.h"
#import "../../AdManager.h"

@interface WideSpaceAdViewController ()

@end

@implementation WideSpaceAdViewController

- (id)initWithAdRation:(AdRation *)adRation engine:(WideSpaceAdEngine *)adEngine config:(NSDictionary *)config
{
    self = [super initWithAdRation:adRation engine:adEngine config:config];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
- (id)initWithAdManager:(AdManager *)adManager type:(NSString *)adType engine:(WideSpaceAdEngine *)engine
{
    self = [super initWithAdManager:adManager type:adType engine:engine];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self.adType isEqualToString:@"banner"] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        self.width = 768;
        self.height = 90;
        adView = [[WSAdSpace alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) sid:self.adEngine.leaderboardSID autoStart:YES autoUpdate:NO delegate:self GPSEnabled:NO];
    }
    else if ([self.adType isEqualToString:@"banner"])
    {
        self.width = 320;
        self.height = 48;
        adView = [[WSAdSpace alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) sid:self.adEngine.bannerSID autoStart:YES autoUpdate:NO delegate:self GPSEnabled:NO];
    }
    else if ([self.adType isEqualToString:@"rectangle"] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        self.width = 300;
        self.height = 300;
        adView = [[WSAdSpace alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) sid:self.adEngine.squareSID autoStart:YES autoUpdate:NO delegate:self GPSEnabled:NO];
    }
    else if ([self.adType isEqualToString:@"rectangle"])
    {
        self.width = 320;
        self.height = 320;
        adView = [[WSAdSpace alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) sid:self.adEngine.rectangleSID autoStart:YES autoUpdate:NO delegate:self GPSEnabled:NO];
    }
    else if ([self.adType isEqualToString:@"interstitial"])
    {
        self.width = 320;
        self.height = 480;
        adView = [[WSAdSpace alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) sid:self.adEngine.interstitialSID autoStart:NO autoUpdate:NO delegate:self GPSEnabled:NO];
    }

    // meta
    AppDeckUserProfile *profile = self.adManager.loader.appDeck.userProfile;
    if (profile.postal)
        [adView setExtraParameter:@"postal" value:profile.postal];
    if (profile.city)
        [adView setExtraParameter:@"city" value:profile.city];
    if (profile.age)
        [adView setExtraParameter:@"age" value:profile.age];
    if (profile.yearOfBirth)
        [adView setExtraParameter:@"yob" value:profile.yearOfBirth];
    if (profile.gender)
        [adView setExtraParameter:@"sex" value:(profile.gender == ProfileGenderMale ? @"1" : @"0")];
    
    adView.gpsEnabled = NO;
    adView.shadowEnabled = NO;
    adView.autoUpdate = NO;
    
    adView.delegate = self;
       
    self.view.clipsToBounds = YES;
    
    [self.view addSubview:adView];
    
    if ([self.adType isEqualToString:@"interstitial"])
        [adView prefetchAd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{
    adView.delegate = nil;
    [adView closeAd];
    [adView stop];
    [adView removeFromSuperview];
}

-(void)dealloc
{
    [self cancel];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - WideSpace delegate

/**
 Provide a specific UIViewController to the WSAdSpace for fetching interface orientation and calculating available screen space. Will be handled automatically if not implemented.
 */
- (UIViewController *)wsParentViewController
{
    if (self.page)
        return (UIViewController *)self.page.loader;
    return self;
}

/**
 AdSpace will close the current ad.
 @param adSpace The AdSpace that is closing the ad.
 @param adType Enum describing the type of ad that is being closed.
 */
- (void)willCloseAd:(WSAdSpace *)adSpace withAdType:(WSAdType)adType
{
    //if ([self.adType isEqualToString:@"interstitial"] == NO)
        self.page.disableAds = YES;
    self.state = AppDeckAdStateClose;
}

/**
 AdSpace closed the current ad.
 @param adSpace The AdSpace that closed the ad.
 @param adType Enum describing the type of ad that was closed.
 */
- (void)didCloseAd:(WSAdSpace *)adSpace withAdType:(WSAdType)adType
{
    //self.state = AppDeckAdStateUnload;
}

/**
 AdSpace will load next ad. This when the AdSpace will present the next item in the ad queue, if the ad queue is empty a new ad will be fetched and instantly run.
 @param adSpace The AdSpace that will load an ad.
 */
- (void)willLoadAd:(WSAdSpace *)adSpace
{
    
}

/**
 AdSpace loaded an ad. This callback fires at the same time as didAnimateIn: (when presentation animation has completed).
 @param adSpace The AdSpace that loaded the ad.
 @param adType Enum describing the type of ad that was loaded.
 */
- (void)didLoadAd:(WSAdSpace *)adSpace withAdType:(WSAdType)adType
{
    if ([self.adType isEqualToString:@"interstitial"] == NO)
    {
        NSLog(@"ad size: %fx%f == %fx%f ?", adSpace.frame.size.width, adSpace.frame.size.height, self.width, self.height);
        // commented as we must wait ad to be animated in to get final size
        //self.state = AppDeckAdStateReady;
    }
}

/**
 AdSpace will start playing a movie or a sound, you should react to this if you are playing audio or video in your app.
 <p>
 Example usage: You should make sure your users do not have a bad user experience where they hear two sounds at the same time while the ad is playing its media.
 </p>
 @param adSpace The AdSpace that has the ad with the media that will start to play.
 @param mediaType Enum describing the media type being started.
 */
- (void)willStartMedia:(WSAdSpace *)adSpace withMediaType:(WSMediaType)mediaType
{
    
}

/**
 AdSpace will stop playing a movie or a sound, you should react to this if you where playing audio or video in your app before the ad started its media. This can occur if your users stop the playing of a video/sound or if the ad is closed.
 <p>
 Example usage: Now is the perfect time for you to resume your audio playing.
 </p>
 @param adSpace The AdSpace that has the ad with the media that stopped playing.
 @param mediaType Enum describing the media type that was stopped.
 @warning This method is NOT called when media completes, only when media forcefully stops.
 */
- (void)didStopMedia:(WSAdSpace *)adSpace withMediaType:(WSMediaType)mediaType
{
    
}

/**
 AdSpace completed media playing. This happens when a video or audio plays its full length (ex. watching a video ad to the end of the video) or if media playback fails.
 @param adSpace The AdSpace has the ad with the media that completed playing.
 @param mediaType Enum describing the media type that completed.
 */
- (void)didCompleteMedia:(WSAdSpace *)adSpace withMediaType:(WSMediaType)mediaType
{
    
}

/**
 AdSpace did not receive any ad from engine (response returned but with no ad), this might be due to impressions already beeing consumed for your AdSpace.
 @param adSpace The AdSpace that received no ad.
 @warning This is not considered as an error.
 */
- (void)didReceiveNoAd:(WSAdSpace *)adSpace
{
    self.state = AppDeckAdStateCancel;
}

/**
 AdSpace failed and is reporting an error, if this happens you should check what error it is and try to handle it.
 <p>
 Its typically a bad idea to just propagate the error messages that comes through here to the user since the cause of the error most likely is not the users fault or nothing the user can do anything about. The WSAdSpace will try to handle the error.
 </p>
 @param adSpace The AdSpace that received the error.
 @param type Enum describing the error type.
 @param message Error description.
 @param error Underlying error.
 */
- (void)didFailWithError:(WSAdSpace *)adSpace withType:(WSErrorType)type message:(NSString *)message error:(NSError *)error
{
    self.state = AppDeckAdStateFailed;
}

/**
 Current ad in AdSpace was expanded.
 @param adSpace The AdSpace holds the ad that was expanded.
 @param expandDirection Enum describing the direction, in which direction the adspace expanded.
 @param finalWidth Width after ad has expanded.
 @param finalHeight Height after ad has expanded.
 */
- (void)didExpandAd:(WSAdSpace *)adSpace withExpandDirection:(WSAnimationDirection)expandDirection finalWidth:(CGFloat)finalWidth finalHeight:(CGFloat)finalHeight
{
    self.width = finalWidth;
    self.height = finalHeight;
}

/**
 Current ad in AdSpace was resized.
 @param adSpace The AdSpace holds the ad that was resized.
 @param finalWidth Width after ad has resized.
 @param finalHeight Height after ad has resized.
 */
- (void)didResizeAd:(WSAdSpace *)adSpace finalWidth:(CGFloat)finalWidth finalHeight:(CGFloat)finalHeight
{
    self.width = finalWidth;
    self.height = finalHeight;
}

/**
 Current ad in AdSpace was collapsed.
 @param adSpace The AdSpace holds the ad that was collapsed.
 @param collapsedDirection Enum describing the direction, in which direction the adspace collapsed.
 @param finalWidth Width after ad has collapsed.
 @param finalHeight Height after ad has collapsed.
 */
- (void)didCollapseAd:(WSAdSpace *)adSpace withCollapsedDirection:(WSAnimationDirection)collapsedDirection finalWidth:(CGFloat)finalWidth finalHeight:(CGFloat)finalHeight
{
    self.state = AppDeckAdStateClose;
}

/**
 AdSpace finished prefetching an ad. The ad is placed in the ad queue and is ready for you to show using runAd.
 
 <p>
 Available WSMediaStatus responses:<br>
 WSMediaStatusNoMedia           = Ad contains no media (regular ad)<br>
 WSMediaStatusMediaCached       = Ad contains media and media is cached<br>
 WSMediaStatusMediaNotCached    = Ad contains media but media is not cached<br>
 </p>
 
 @param adSpace The AdSpace that prefetched an ad.
 @param mediaStatus Enum describing the status of media what media the ad contains. (not cached, cached or no media).
 */
- (void)didPrefetchAd:(WSAdSpace *)adSpace withMediaStatus:(WSMediaStatus)mediaStatus
{
    NSLog(@"prefetch %ld", (long)WSMediaStatusMediaCached);
    
    if (WSMediaStatusMediaCached >= 1) {
        [adView runAd];
    }
    
    // this is for Intersticial
    //if (mediaStatus == WSMediaStatusNoMedia)
    //    self.state = AppDeckAdStateFailed;
    //else
    //    self.state = AppDeckAdStateReady;
}

/**
 AdSpace will perform an in animation of an ad.
 @param adSpace The AdSpace that will animate an ad.
 */
- (void)willAnimateIn:(WSAdSpace *)adSpace
{
    self.width = adSpace.frame.size.width;
    self.height = adSpace.frame.size.height;
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.width, self.height);
    self.state = AppDeckAdStateReady;
}

/**
 AdSpace completed in animation of an ad.
 @param adSpace The AdSpace that completed the animation of an ad.
 */
- (void)didAnimateIn:(WSAdSpace *)adSpace
{
/*    self.width = adSpace.frame.size.width;
    self.height = adSpace.frame.size.height;
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.width, self.height);
    self.state = AppDeckAdStateReady;*/
}

/**
 AdSpace will perform an out animation of an ad.
 @param adSpace The AdSpace that will animate an ad.
 */
- (void)willAnimateOut:(WSAdSpace *)adSpace
{
    
}

/**
 AdSpace completed out animation of an ad.
 @param adSpace The AdSpace that completed the animation of an ad.
 */
- (void)didAnimateOut:(WSAdSpace *)adSpace
{
    
}


@end
