//
//  AdRation.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 01/09/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import "AdRation.h"
#import "AppDeckAdEngine.h"


@implementation AdRation

-(id)initWithScenario:(AdScenario *)adScenario config:(NSDictionary *)config
{
    self = [self init];
    
    if (self)
    {
        self.adScenario = adScenario;
        self.adManager = self.adScenario.adPlacement.adRequest.adManager;
        self.adRequest = self.adScenario.adPlacement.adRequest;
        self.config = config;
        self.state = AdRationStateNotSet;
        
        [self loadConfiguration:self.config];
    }
    return self;
}

-(BOOL)loadConfiguration:(NSDictionary *)config
{
    self.rationId = [config objectForKey:@"id"];
    self.rationType = [config objectForKey:@"type"];

    // format
    NSDictionary *format = [config objectForKey:@"format"];
    if (format && [[format class] isSubclassOfClass:[NSDictionary class]])
    {
        self.formatId = [format objectForKey:@"id"];
        self.formatType = [format objectForKey:@"type"];
        self.formatWidth = [[format objectForKey:@"width"] floatValue];
        self.formatHeight = [[format objectForKey:@"height"] floatValue];
    }
    
    // settings
    self.settings = [config objectForKey:@"settings"];
    if (!self.settings || ![[self.settings class] isSubclassOfClass:[NSDictionary class]])
        self.settings = @{};
    
    // offers
    NSDictionary *offer = [config objectForKey:@"offer"];
    if (offer && [[offer class] isSubclassOfClass:[NSDictionary class]])
    {
        self.offerId = [offer objectForKey:@"id"];
        self.offerType = [offer objectForKey:@"type"];
        self.offerSettings = [offer objectForKey:@"settings"];
        if (self.offerSettings == nil || ![[self.offerSettings class] isSubclassOfClass:[NSDictionary class]])
            self.offerSettings = @{};
    }
    
    return YES;
}

-(void)cancel
{
    
}

-(void)dealloc
{
    [self cancel];
}

-(BOOL)start
{
    self.adEngine = [self.adManager adEngineFromId:self.offerId type:self.offerType config:self.offerSettings];

    if (self.adEngine == nil)
    {
        self.state = AdRationStateFailed;
        return NO;
    }

    self.adViewController = [self.adEngine adViewControllerFromAdRation:self andAdConfig:self.settings];

    if (self.adViewController == nil)
    {
        self.state = AdRationStateFailed;
        return NO;
    }
    
    // preload this ad in fakeviewcontollers
    [self.adManager.fakeCtl addChildViewController:self.adViewController];
    [self.adManager.fakeCtl.view addSubview:self.adViewController.view];
    
    self.state = AdRationStateNew;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkRation:) userInfo:nil repeats:YES];
    return YES;
}

-(void)checkRation:(NSTimer *)origin
{
    // we are working with an ad, check the state

    if (self.adViewController.state == AppDeckAdStateEmpty) // ad just created
        ; // wait more

    else if (self.adViewController.state == AppDeckAdStateLoad) // ad have been requested to SDK
        ; // do nothing
    
    else if (self.adViewController.state == AppDeckAdStateReady) // ad is ready to display
    {
        if ([self.adViewController.adType isEqualToString:@"rectangle"])
            self.adRequest.page.rectangleAd = (AppDeckAdViewController *)self.adViewController;
        else if ([self.adViewController.adType isEqualToString:@"interticial"])
            self.adRequest.page.interstitialAd = (AppDeckAdViewController *)self.adViewController;
        else if ([self.adViewController.adType isEqualToString:@"banner"])
            self.adRequest.page.bannerAd = (AppDeckAdViewController *)self.adViewController;
        else
        {
            self.adViewController.state = AppDeckAdStateFailed;
            return;
        }
        // disable futur checks
        [timer invalidate];
        timer = nil;
    }
    
    else if (self.adViewController.state == AppDeckAdStateFailed) // ad failed to load
    {
        self.state = AdRationStateFailed;
        self.adViewController = nil;
    }
    
    else if (self.adViewController.state == AppDeckAdStateCancel) // ad was onscreen but was cancel by SDK
    {
        self.state = AdRationStateFailed;
    }

    else if (self.adViewController.state == AppDeckAdStateAppear) // ad is on screen
    {
        NSLog(@"this should not happen ...");
    }
    
    else if (self.adViewController.state == AppDeckAdStateClose) // user request ad to be removed (close button)
    {
        NSLog(@"this should not happen ...");
    }

}


@end
