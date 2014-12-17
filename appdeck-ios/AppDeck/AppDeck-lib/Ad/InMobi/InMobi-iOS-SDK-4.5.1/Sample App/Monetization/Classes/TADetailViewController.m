//
//  TADetailViewController.m
//  Test Application
//
//  Copyright (c) 2012 InMobi Inc. All rights reserved.
//

#import "TADetailViewController.h"
#import "TAAppDelegate.h"
//#import "MMAdView.h"
//#import "GADBannerView.h"
//#import <iAd/iAd.h>

#define TIMER_INTERVAL @"60"

@interface TADetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;

@end

@implementation TADetailViewController

@synthesize detailItem;
@synthesize masterPopoverController;
@synthesize activityIndicator;
@synthesize statusLabel;
@synthesize statusView;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        detailItem = newDetailItem;
        
        BOOL iPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
        iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
        if (iPad) {
            [self configureView];
        }
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

-(void)loadAdRequest {
    
    // Update the user interface for the detail item.
    if (self.detailItem) {
        if([[self.detailItem objectForKey:@"type"] isEqualToString:@"Banner"]) {
            NSLog(@"Initializing %@",[self.detailItem objectForKey:@"title"]);
            
            CGSize adSize = CGSizeFromString([self.detailItem objectForKey:@"dimension"]);
            CGRect viewFrame = self.view.frame;
            // Center align the ad
            CGRect adFrame = CGRectMake((viewFrame.size.width - adSize.width) / 2, 70, adSize.width, adSize.height);
            
            self.title = [self.detailItem objectForKey:@"title"];
            adView = [[IMBanner alloc] initWithFrame:adFrame
                                               appId:BANNER_APP_ID
                                              adSize:[[self.detailItem objectForKey:@"id"] integerValue]];
            
            [adView setDelegate:self];
            [adView loadBanner];
            
            [activityIndicator startAnimating];
            statusLabel.hidden = NO;
            
            self.statusView.frame = CGRectMake(0, adFrame.origin.y + adFrame.size.height + 5, self.view.frame.size.width, self.view.frame.size.height - adFrame.size.height);
            
        } else {
            adInterstitial = [[IMInterstitial alloc] initWithAppId:INTERSTITIAL_APP_ID];
            adInterstitial.delegate = self;
            
            [activityIndicator startAnimating];
            statusLabel.hidden = NO;
            [adInterstitial loadInterstitial];
            
            self.statusView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
    }
}

- (void)configureView {
    if(adView) {
        adView.hidden = YES;
        [adView setDelegate:nil];
        [adView removeFromSuperview];
        adView = nil;
    }
    
    [self loadAdRequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    statusLabel.hidden = YES;
    [activityIndicator stopAnimating];
    [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"InMobi Monetization", @"InMobi Monetization");
    }
    return self;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Select Format", @"InMobi");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Banner Request Notifications

// Sent when an ad request was successful
- (void)bannerDidReceiveAd:(IMBanner *)banner {
    NSLog(@"Finished loading %@",[self.detailItem objectForKey:@"title"]);
    
    [activityIndicator stopAnimating];
    statusLabel.text = [NSString stringWithFormat:@"Loaded ad successfully."];
    
    if(![self.view.subviews containsObject:adView])
        [self.view addSubview:adView];
}

// Sent when the ad request failed. Please check the error code and
// localizedDescription for more information on wy this occured
- (void)banner:(IMBanner *)banner didFailToReceiveAdWithError:(IMError *)error {
    
    NSString *errorMessage = [NSString stringWithFormat:@"Loading ad (%@) failed. Error code: %d, message: %@", [self.detailItem objectForKey:@"title"], [error code], [error localizedDescription]];
    NSLog(@"%@", errorMessage);
    
    [activityIndicator stopAnimating];
    statusLabel.text = errorMessage;
}

#pragma mark Banner Interaction Notifications

// Called when the banner is tapped or interacted with by the user
// Optional data is available to publishers to act on when using
// monetization platform to render promotional ads.
-(void)bannerDidInteract:(IMBanner *)banner withParams:(NSDictionary *)dictionary {
    NSLog(@"Interaction with Banner happened");
}

// Sent just before presenting the user a full screen view, in response to
// tapping on an ad.  Use this opportunity to stop animations, time sensitive
// interactions, etc.
- (void)bannerWillPresentScreen:(IMBanner *)banner {
    NSLog(@"Preparing to present screen");
}

// Sent just before dismissing a full screen view.
- (void)bannerWillDismissScreen:(IMBanner *)banner {
    NSLog(@"Preparing to dismiss screen");
}

// Sent just after dismissing a full screen view.  Use this opportunity to
// restart anything you may have stopped as part of adViewWillPresentScreen:
- (void)bannerDidDismissScreen:(IMBanner *)banner {
    NSLog(@"Dismissed screen");
}

// Sent just before the application will background or terminate because the
// user clicked on an ad that will launch another application (such as the App
// Store).
- (void)bannerWillLeaveApplication:(IMBanner *)banner {
    NSLog(@"Preparing to leave application");
}

#pragma mark Interstitial Request Notifications

// Sent when an interstitial ad request succeeded.
- (void)interstitialDidReceiveAd:(IMInterstitial *)ad {
    NSLog(@"Loaded %@",[self.detailItem objectForKey:@"title"]);
    
    [activityIndicator stopAnimating];
    statusLabel.text = @"Loaded Ad successfully";
    
    [ad presentInterstitialAnimated:YES];
}
// Sent when an interstitial ad request failed
- (void)interstitial:(IMInterstitial *)ad didFailToReceiveAdWithError:(IMError *)error {
    
    NSString *errorMessage = [NSString stringWithFormat:@"Loading ad (%@) failed. Error code: %d, message: %@", [self.detailItem objectForKey:@"title"], [error code], [error localizedDescription]];
    NSLog(@"%@", errorMessage);
    
    [activityIndicator stopAnimating];
    statusLabel.text = errorMessage;
}

#pragma mark Interstitial Interaction Notifications

// Sent just before presenting an interstitial.  After this method finishes the
// interstitial will animate onto the screen.  Use this opportunity to stop
// animations and save the state of your application in case the user leaves
// while the interstitial is on screen (e.g. to visit the App Store from a link
// on the interstitial).
- (void)interstitialWillPresentScreen:(IMInterstitial *)ad {
    NSLog(@"Preparing to present screen");
}

// Sent before the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(IMInterstitial *)ad {
    NSLog(@"Preparing to dismiss screen");
}

// Sent just after dismissing an interstitial and it has animated off the
// screen.
- (void)interstitialDidDismissScreen:(IMInterstitial *)ad {
    NSLog(@"Dismissed screen");
}

// Sent just before the application will background or terminate because the
// user clicked on an ad that will launch another application (such as the App
// Store).  The normal UIApplicationDelegate methods, like
// applicationDidEnterBackground:, will be called immediately before this.
- (void)interstitialWillLeaveApplication:(IMInterstitial *)ad {
    NSLog(@"Preparing to leave application");
}

// Called when the interstitial is tapped or interacted with by the user
// Optional data is available to publishers to act on when using
// monetization platform to render promotional ads.
-(void)interstitialDidInteract:(IMInterstitial *)ad withParams:(NSDictionary *)dictionary {
    NSLog(@"Interaction with Interstitial happened");
}

#pragma mark - dealloc

-(void)dealloc {
    [adView setDelegate:nil];
    [adView removeFromSuperview];
    
    [adInterstitial setDelegate:nil];
}

@end
