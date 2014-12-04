//
//  MMediaRectangleAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MMediaRectangleAdViewController.h"

@interface MMediaRectangleAdViewController ()

@end

@implementation MMediaRectangleAdViewController

- (id)initWithAdManager:(AdManager *)adManager andEngine:(MMediaAdEngine *)adEngine
{
    self = [super initWithAdManager:adManager andEngine:adEngine];
    if (self) {
        // Custom initialization
        self.width = 300;
        self.height = 250;
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
    //                          requestWithLocation:appDelegate.locationManager.location];
    
    self.view.frame = CGRectMake(0,0,300,250);
    
    // Replace YOUR_APID with the APID provided to you by Millennial Media
    adview = [[MMAdView alloc] initWithFrame:CGRectMake(0,0,300,250) apid:self.adEngine.rectangleAPID
                          rootViewController:self];
    [self.view addSubview:adview];
    
    //    MMediaBannerAdViewController *_self = self;
    
    [adview getAdWithRequest:request onCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"RECTANGLE AD REQUEST SUCCEEDED");
            self.state = AppDeckAdStateReady;
        }
        else {
            NSLog(@"RECTANGLE AD REQUEST FAILED WITH ERROR: %@", error);
            self.state = AppDeckAdStateFailed;
        }
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
