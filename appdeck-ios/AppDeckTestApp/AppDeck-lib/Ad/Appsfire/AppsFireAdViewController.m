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
        // only interticial
        if (![self.adType isEqualToString:@"interticial"])
        {
            NSLog(@"AppsFireAdViewController only handle interticial");
            return nil;
        }
    }
    return self;
}

/*
- (id)initWithAdManager:(AdManager *)adManager type:(NSString *)adType engine:(AppsFireAdEngine *)engine
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
    [AppsfireSDK connectWithAPIKey:self.adEngine.api_key];
#ifdef DEBUG
    [AppsfireAdSDK setDebugModeEnabled:YES];
#endif
    [AppsfireAdSDK prepare];
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
    [AppsfireAdSDK requestModalAd:AFAdSDKModalTypeUraMaki withController:(UIViewController *)ctl];
}

#pragma mark - AppsFire Ad Delegate

/*!
 *  @brief Called when the library is initialized.
 */
- (void)adUnitDidInitialize
{
    
}

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
 */
- (void)modalAdRequestDidFailWithError:(NSError *)error
{
    NSLog(@"Ad Unit Request Failed = %@", error.localizedDescription);
    self.state = AppDeckAdStateFailed;
    /*
     // optional, you can implement a reaction
     switch (error.code) {
     case AFSDKErrorCodeAdvertisingBadCall:
     break;
     case AFSDKErrorCodeAdvertisingNoAd:
     break;
     case AFSDKErrorCodeAdvertisingAlreadyDisplayed:
     break;
     default:
     break;
     }
     */
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
