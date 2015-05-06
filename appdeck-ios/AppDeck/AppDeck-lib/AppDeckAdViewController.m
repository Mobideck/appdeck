//
//  AppDeckAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeckAdViewController.h"

#import "AdManager.h"
#import "AppDeckAdEngine.h"
#import "AdRation.h"

@interface AppDeckAdViewController ()

@end

@implementation AppDeckAdViewController

/*- (id)initWithAdManager:(AdManager *)adManager type:(NSString *)adType engine:(AppDeckAdEngine *)adEngine
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.adManager = adManager;
        self.adEngine = adEngine;
        self.adType = adType;
    }
    return self;
}*/

- (id)initWithAdRation:(AdRation *)adRation engine:(AppDeckAdEngine *)adEngine config:(NSDictionary *)config
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.adEngine = adEngine;
        self.adManager = adEngine.adManager;
        self.adRation = adRation;
        self.adConfig = config;
        
        // auto detect adType
        AdPlacement *adPlacement = self.adRation.adScenario.adPlacement;
        self.adType = adPlacement.type;
        if ([adPlacement.type isEqualToString:@"banner"] && [adPlacement.position isEqualToString:@"top"])
        {
            self.adType = @"rectangle";
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.opaque = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setState:(AppDeckAdState)state
{
    _state = state;
//    NSLog(@"AdState: %d", state);
    if (_state == AppDeckAdStateReady)
        [self adIsReady];
    else if (_state == AppDeckAdStateFailed)
        [self adDidFailed];
    else if (_state == AppDeckAdStateCancel)
        [self adDidCancel];
    else if (_state == AppDeckAdStateLoad)
        [self adWillLoadInViewController:self.page];
    else if (_state == AppDeckAdStateAppear)
        [self adWillAppearInViewController:self.page];
/*    else if (_state == AppDeckAdStateDisappear)
        [self adWillDisappearInViewController:self.page];
    else if (_state == AppDeckAdStateUnload)
        [self adDidUnloadFromViewController:self.page];*/
    else if (_state == AppDeckAdStateClose)
    {
        //self.page.disableAds = YES;
        [self adDidUnloadFromViewController:self.page];
    }
    [self.adManager ad:self didUpdateState:_state];    
}

-(void)cancel
{
    
}

#pragma mark - default Ad Life Cycle implementation

-(void)adIsReady
{
    
}

-(void)adDidFailed
{
    
}

-(void)adDidCancel
{
    
}

-(void)adWillLoadInViewController:(LoaderChildViewController *)ctl
{
    
}


-(void)adWillAppearInViewController:(LoaderChildViewController *)ctl
{
    
}

-(void)adWillDisappearInViewController:(LoaderChildViewController *)ctl
{
    
}

-(void)adDidUnloadFromViewController:(LoaderChildViewController *)ctl
{
    if (![ctl isKindOfClass:[PageViewController class]])
        return;
    
    PageViewController *page = (PageViewController *)ctl;
    
    if (page.bannerAd == self)
        page.bannerAd = nil;
    else if (page.rectangleAd == self)
        page.rectangleAd = nil;
    else if (page.interstitialAd == self)
        page.interstitialAd = nil;
    
}

@end
