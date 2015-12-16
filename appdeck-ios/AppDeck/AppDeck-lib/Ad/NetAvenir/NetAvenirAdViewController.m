//
//  NetAvenirAdViewController.m
//  Oxom
//
//  Created by Sébastien Sans on 13/10/2015.
//  Copyright (c) 2015 Sébastien Sans. All rights reserved.
//

#import "NetAvenirAdViewController.h"

@interface NetAvenirAdViewController () {
    NAAdPlacement *placement;
}
@end

@implementation NetAvenirAdViewController

- (id)initWithAdRation:(AdRation *)adRation engine:(NetAvenirAdEngine *)adEngine config:(NSDictionary *)config
{
    self = [super initWithAdRation:adRation engine:adEngine config:config];
    if (self) {
        // Custom initialization
        placement = nil;
        self.zid = [NSString stringWithFormat:@"%@", [config objectForKey:@"zid"]];
        self.state = AppDeckAdStateEmpty;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.adType isEqualToString:@"banner"] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        self.width = 768;
        self.height = 128;
    }
    else if ([self.adType isEqualToString:@"banner"])
    {
        self.width = 320;
        self.height = 50;
    }
    else if ([self.adType isEqualToString:@"rectangle"] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        self.width = 300;
        self.height = 300;
    }
    else if ([self.adType isEqualToString:@"rectangle"])
    {
        self.width = 320;
        self.height = 320;
    }
    else if ([self.adType isEqualToString:@"interstitial"])
    {
        self.width = 320;
        self.height = 480;
    }
    placement = [[NAAdPlacement alloc] initWithPlacementIdentifier:self.zid];
    [placement setDelegate:self];
    self.state = AppDeckAdStateReady;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    placement = nil;
}

-(void)cancel
{
    placement = nil;
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.adType isEqualToString:@"interstitial"])
        [placement presentInterstitialForViewController:self];
    else
        [placement presentBannerForViewController:self withPosition:NAAdPositionBottom];
}

#pragma mark NAAdPlacementDelegate protocol -

/*!
 * @method didReceiveAd:
 *
 * @discussion
 * Called when the placement did receive ad.
 */
- (void)didReceiveAd {
    self.state = AppDeckAdStateReady;
}

/*!
 * @method didFailToReceiveAd:
 *
 * @discussion
 * Called when the placement failed to receive ad.
 *
 */
- (void)didFailToReceiveAd {
    self.state = AppDeckAdStateFailed;
}

/*!
 * @method didDismissAd:
 *
 * @discussion
 * Called when the placement did dismiss (usefull for interstitials)
 *
 */
- (void)didDismissAd {
    self.state = AppDeckAdStateClose;
}


@end
