//
//  iPhoneMobileBannerViewController.m
//  ConversantSampleApp
//
//  Created by Jeff Carlson on 5/12/14.
//  Copyright (c) 2014 Conversant. All rights reserved.
//

#import "iPhoneMobileBannerViewController.h"

#import "GSAdDelegate.h"
#import "GSMobileBannerAdView.h"
#import "GSSDKInfo.h"

@interface iPhoneMobileBannerViewController () <GSAdDelegate>

@property (nonatomic, strong) GSMobileBannerAdView *myBannerAd;
@property (nonatomic, weak) IBOutlet UIButton *bannerButton;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@end

@implementation iPhoneMobileBannerViewController

#pragma mark - UIViewController -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    
    self.myBannerAd = [[GSMobileBannerAdView alloc] initWithDelegate:self];
    
    [self.myBannerAd setFrame:CGRectMake(0, 20, kGSMobileBannerWidth, kGSMobileBannerHeight)];
}

#pragma mark - Conversant UIViewController -

- (UIViewController *)greystripeBannerDisplayViewController
{
    return self;
}

#pragma mark - IBAction Button -

- (IBAction)bannerButtonPressed:(id)sender
{
    self.statusLabel.text = @"Fetching an ad...";
    [self.bannerButton setEnabled:NO];
    
    // Fetch Banner Ad
    [self.myBannerAd fetch];
}

#pragma mark - Conversant Protocol Methods -

- (BOOL)greystripeBannerAutoload
{
    // Return TRUE to autoload an ad
    return FALSE;
}

- (BOOL)greystripeShouldLogAdID
{
    // Return TRUE to log the AdID in an NSLog. Useful for debugging purposes
    return FALSE;
}

- (void)greystripeAdFetchSucceeded:(id<GSAd>)a_ad
{
    if (a_ad == self.myBannerAd)
    {
        [self.view addSubview:self.myBannerAd];
        
        self.statusLabel.text = @"Small Banner Ad successfully fetched.";
        
        [self.bannerButton setEnabled:YES];
    }
    
    // Use the a_ad object to return the adID value for debugging purposes
    NSString *GSAdId = [a_ad adID];
    NSLog(@"Ad ID: %@", GSAdId);
}

- (void)greystripeAdFetchFailed:(id<GSAd>)a_ad withError:(GSAdError)a_error
{
    NSString *errorString =  @"";
    
    switch(a_error)
    {
        case kGSNoNetwork:
            errorString = @"Error: No network connection available.";
            break;
        case kGSNoAd:
            errorString = @"Error: No ad available from server.";
            break;
        case kGSTimeout:
            errorString = @"Error: Fetch request timed out.";
            break;
        case kGSServerError:
            errorString = @"Error: Conversant returned a server error.";
            break;
        case kGSInvalidApplicationIdentifier:
            errorString = @"Error: Invalid or missing application identifier.";
            break;
        case kGSAdExpired:
            errorString = @"Error: Previously fetched ad expired.";
            break;
        case kGSFetchLimitExceeded:
            errorString = @"Error: Too many requests too quickly.";
            break;
        case kGSUnknown:
            errorString = @"Error: An unknown error has occurred.";
            break;
        default:
            errorString = @"An invalid error code was returned. Thats really bad!";
    }
    self.statusLabel.text = [NSString stringWithFormat:@"%@",errorString];
    [self.bannerButton setEnabled:YES];
}

- (void)greystripeAdClickedThrough:(id<GSAd>)a_ad
{
    self.statusLabel.text = @"Conversant ad was clicked.";
}

- (void)greystripeBannerWillExpand:(id<GSAd>)a_ad
{
    self.statusLabel.text = @"Conversant ad expanded.";
}

- (void)greystripeBannerDidCollapse:(id<GSAd>)a_ad
{
    self.statusLabel.text = @"Conversant ad collapsed.";
}

#pragma mark - Banner Rotation Management -

- (void) viewWillLayoutSubviews
{
    [self.myBannerAd setFrame:CGRectMake(([self.view bounds].size.width - kGSMobileBannerWidth)/2, 20, kGSMobileBannerWidth, kGSMobileBannerHeight)];
}

#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark iOS 6 Orientation Support

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
