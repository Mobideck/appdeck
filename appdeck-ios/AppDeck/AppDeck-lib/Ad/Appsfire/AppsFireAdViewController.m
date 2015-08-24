//
//  AppsFireAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 25/12/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppsFireAdViewController.h"

@interface AppsFireAdViewController ()

@end

@implementation AppsFireAdViewController

- (id)initWithAdRation:(AdRation *)adRation engine:(AppsFireAdEngine *)adEngine config:(NSDictionary *)config
{
    self = [super initWithAdRation:adRation engine:adEngine config:config];
    if (self) {
        // only interstitial
        if (![self.adType isEqualToString:@"interstitial"])
        {
            NSLog(@"AppsFireAdViewController only handle interstitial");
            return nil;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [AppsfireSDK connectWithAPIKey:self.adEngine.api_key];
    [AppsfireSDK connectWithSDKToken:self.adEngine.api_key secretKey:self.adEngine.api_secret features:AFSDKFeatureMonetization parameters:nil];
    
    
#ifdef DEBUG
    [AppsfireAdSDK setDebugModeEnabled:YES];
#endif
    // check if there is an ad available, and that none is currently displayed
    if ([AppsfireAdSDK isThereAModalAdAvailableForType:AFAdSDKModalTypeSushi] == AFAdSDKAdAvailabilityYes && ![AppsfireAdSDK isModalAdDisplayed]) {

    } else {
        self.state = AppDeckAdStateCancel;
    }
    
    //[AppsfireAdSDK prepare];
    [AppsfireAdSDK setDelegate:self];
    self.width = 0;
    self.height = 0;
    self.view.frame = CGRectZero;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{

}

#pragma mark - AppDeckAdViewController

-(void)adWillAppearInViewController:(LoaderChildViewController *)ctl
{

//    [AppsfireAdSDK requestModalAd:AFAdSDKModalTypeUraMaki withController:(UIViewController *)ctl];
    
    // delay a bit the request because ‘applicationDidBecomeActive:’ could prevent a part of the animation
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [AppsfireAdSDK requestModalAd:AFAdSDKModalTypeSushi withController:(UIViewController *)ctl withDelegate:self];
    });
}

#pragma mark - AppsFire Ad Delegate

/*!
 *  @brief Called when ads were refreshed and that at least one modal ad is available.
 *  @since 2.4
 *
 *  @note You are responsible to check whether there is a modal ad available for the format you are willing to display.
 */
- (void)modalAdsRefreshedAndAvailable
{
    self.state = AppDeckAdStateReady;
}

/*!
 *  @brief Called when ads were refreshed but that none is available for any modal format.
 *  @since 2.4
 *
 *  @note You could decide to act differently knowing that there is currently no ad to display.
 */
- (void)modalAdsRefreshedAndNotAvailable
{
    self.state = AppDeckAdStateFailed;
}

#pragma mark - AppsFire Modal Ad Delegate

/*!
 *  @brief Called when there is a modal ad available,
 *  even if there are some pending requests (before handling the requests queue).
 */
- (void)modalAdIsReadyForRequest
{
    self.state = AppDeckAdStateReady;
}

/*!
 *  @brief Called when a modal ad is going to be presented on the screen.
 *  Depending the state of your application, you may want to cancel the display of the ad.
 *
 *  @return `YES` if you authorize the ad to display, `NO` if the ad shouldn't display.
 *  If this method isn't implemented, the default value is `YES`.
 *  If you return `NO`, the request will be canceled and an error will be fired through `modalAdRequestDidFailWithError:`
 */
- (BOOL)shouldDisplayModalAd
{
    return YES;
}

/*!
 *  @brief Called when a modal ad failed to present.
 *  You can use the code in the NSError to analyze precisely what went wrong.
 *
 *  @param error The error object filled with the appropriate 'code' and 'localizedDescription'.
 */
- (void)modalAdRequestDidFailWithError:(NSError *)error
{
    NSLog(@"Ad Unit Request Failed = %@", error.localizedDescription);
    self.state = AppDeckAdStateFailed;
}

/*!
 *  @brief Called when the modal ad is going to be dismissed.
 *
 *  @note In case of in-app download, the method is called when the last modal disappears.
 */
- (void)modalAdWillDisappear
{
    
}

/*!
 *  @brief Called when the modal ad was dismissed.
 */
- (void)modalAdDidDisappear
{
    self.state = AppDeckAdStateClose;
}

@end
