//
//  MMediaBannerAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MMediaBannerAdViewController.h"

@interface MMediaBannerAdViewController ()

@end

@implementation MMediaBannerAdViewController

- (id)initWithAdManager:(AdManager *)adManager andEngine:(MMediaAdEngine *)adEngine
{
    self = [super initWithAdManager:adManager andEngine:adEngine];
    if (self) {
        // Custom initialization
        self.width = 320;
        self.height = 50;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //MMRequest Object
    request = [MMRequest request];
    [self.adEngine passMetadata:request];
//                          requestWithLocation:appDelegate.locationManager.location];
    
    self.view.frame = MILLENNIAL_AD_VIEW_FRAME;
    
    // Replace YOUR_APID with the APID provided to you by Millennial Media
    adview = [[MMAdView alloc] initWithFrame:MILLENNIAL_AD_VIEW_FRAME apid:self.adEngine.bannerAPID
                                    rootViewController:self];
    [self.view addSubview:adview];
    
//    MMediaBannerAdViewController *_self = self;
    
    [adview getAdWithRequest:request onCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"BANNER AD REQUEST SUCCEEDED");
            self.state = AppDeckAdStateReady;
        }
        else {
            NSLog(@"BANNER AD REQUEST FAILED WITH ERROR: %@", error);
            self.state = AppDeckAdStateFailed;        
        }

    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)adWillLoadInViewController:(LoaderChildViewController *)ctl
{
    adview.rootViewController = (UIViewController *)ctl;
}

@end
