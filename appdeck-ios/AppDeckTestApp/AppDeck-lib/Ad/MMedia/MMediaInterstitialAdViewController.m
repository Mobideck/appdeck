//
//  MMediaInterstitialAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MMediaInterstitialAdViewController.h"
#import "PageViewController.h"
@interface MMediaInterstitialAdViewController ()

@end

@implementation MMediaInterstitialAdViewController

- (id)initWithAdManager:(AdManager *)adManager andEngine:(MMediaAdEngine *)adEngine
{
    self = [super initWithAdManager:adManager andEngine:adEngine];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //MMRequest Object
    request = [MMRequest request];
    [self.adEngine passMetadata:request];
    
    //Replace YOUR_APID with the APID provided to you by Millennial Media
    [MMInterstitial fetchWithRequest:request
                                apid:self.adEngine.InterstitialAPID
                        onCompletion:^(BOOL success, NSError *error) {
                            if (success) {
                                NSLog(@"Ad available");
                                self.state = AppDeckAdStateReady;
                            }
                            else {
                                NSLog(@"Error fetching ad: %@", error);
                                self.state = AppDeckAdStateFailed;
                            }
                        }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    /*
    image.frame = CGRectMake(self.view.frame.size.width / 2 - image.frame.size.width / 2,
                             self.view.frame.size.height / 2 - image.frame.size.height / 2,
                             image.frame.size.width, image.frame.size.height);
     */
}

-(void)adWillLoadInViewController:(LoaderChildViewController *)ctl
{
    // double check
    if ([MMInterstitial isAdAvailableForApid:self.adEngine.InterstitialAPID])
    {
        [MMInterstitial displayForApid:self.adEngine.InterstitialAPID
                    fromViewController:self
                       withOrientation:0
                          onCompletion:^(BOOL success, NSError *error) {
                              PageViewController *page = (PageViewController *)self.page;
                              page.interstitialAd = nil;
                          }];
    }
}

@end
