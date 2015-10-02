//
//  AppsFireAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 25/12/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppsFireAdViewController.h"

#import "../../LoaderChildViewController.h"
#import "../../PageViewController.h"
#import "../../LoaderChildViewController.h"
#import "../../AppDeck.h"
#import "../../AppDeckUserProfile.h"
#import "../../AdManager.h"

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
    [AppsfireAdSDK setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{

}

#pragma mark - AppsFire Modal Ad Delegate

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
 *  @brief Called when the modal ad is going to be presented.
 */
- (void)modalAdWillAppear
{
    
}

/*!
 *  @brief Called when the modal ad was presented.
 */
- (void)modalAdDidAppear
{
    
}

/*!
 *  @brief Called when the modal ad was clicked.
 */
- (void)modalAdDidRecordClick
{
    
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

/*!
 *  @brief Called when ads were refreshed and that at least one modal ad is available.
 *  @since 2.4
 *
 *  @note You are responsible to check whether there is a modal ad available for the format you are willing to display.
 */
- (void)modalAdsRefreshedAndAvailable
{
    if ([AppsfireAdSDK isThereAModalAdAvailableForType:self.adEngine.type] == AFAdSDKAdAvailabilityYes) {
        UIViewController *ctl = self.adManager.loader;
        [AppsfireAdSDK requestModalAd:self.adEngine.type withController:ctl withDelegate:self];
        self.state = AppDeckAdStateReady;
    } else {
        self.state = AppDeckAdStateFailed;
    }
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

@end
