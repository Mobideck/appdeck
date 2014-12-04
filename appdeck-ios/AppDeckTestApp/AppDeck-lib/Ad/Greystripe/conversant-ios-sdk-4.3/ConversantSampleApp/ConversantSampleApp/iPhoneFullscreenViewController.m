//
//  iPhoneFullscreenViewController.m
//  ConversantSampleApp
//
//  Created by Jeff Carlson on 5/12/14.
//  Copyright (c) 2014 Conversant. All rights reserved.
//

#import "iPhoneFullscreenViewController.h"

#import "GSAdDelegate.h"
#import "GSFullscreenAd.h"
#import "GSSDKInfo.h"

@interface iPhoneFullscreenViewController () <GSAdDelegate>

@property (nonatomic, strong) GSFullscreenAd *myFullscreenAd;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIButton *fetchFullscreenButton;
@property (nonatomic, weak) IBOutlet UIButton *displayFullscreenButton;

@end

@implementation iPhoneFullscreenViewController

@synthesize displayFullscreenButton;
@synthesize fetchFullscreenButton;
@synthesize myFullscreenAd;
@synthesize statusLabel;

#pragma mark - UIViewController -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Init my fullscren ad object, and set the delegate to be this ViewController
    self.myFullscreenAd = [[GSFullscreenAd alloc] initWithDelegate:self];
}

#pragma mark - IBAction Buttons -

- (IBAction)fetchFullscreenButtonPressed:(id)sender
{
    self.statusLabel.text = @"Fetching an ad...";
    [fetchFullscreenButton setEnabled:NO];
    
    // Fetch Fullscreen Ad
    [myFullscreenAd fetch];
}

- (IBAction)displayFullscreenButtonPressed:(id)sender
{
    self.statusLabel.text = @"Display Fullscreen Ad.";
    
    // Display Fullscreen Ad
    [myFullscreenAd displayFromViewController:self];
    
    [displayFullscreenButton setEnabled:NO];
    [fetchFullscreenButton setEnabled:YES];
}

#pragma mark - Conversant Protocol Methods -

- (BOOL)greystripeShouldLogAdID
{
    // Return TRUE to log the AdID in an NSLog. Useful for debugging purposes.
    return FALSE;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (void)greystripeAdFetchSucceeded:(id<GSAd>)a_ad
{
    if (a_ad == myFullscreenAd)
    {
        self.statusLabel.text = @"Fullscreen Ad successfully fetched.";
        [displayFullscreenButton setEnabled:YES];
    }
    
    // Use the a_ad object to return the adID value for debugging purposes
    NSString *gsAdId = [a_ad adID];
    NSLog(@"Ad ID: %@", gsAdId);
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
    [fetchFullscreenButton setEnabled:YES];
}

- (void)greystripeAdClickedThrough:(id<GSAd>)a_ad
{
    self.statusLabel.text = @"Conversant ad was clicked.";
}

- (void)greystripeWillPresentModalViewController
{
    self.statusLabel.text = @"Conversant opening fullscreen.";
}

- (void)greystripeWillDismissModalViewController
{
    self.statusLabel.text = @"Conversant closing fullscreen.";
}

- (void)greystripeDidDismissModalViewController
{
    self.statusLabel.text = @"Conversant closed fullscreen.";
}

#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Used for demo app presentation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
