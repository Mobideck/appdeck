//
//  iPadViewController.m
//  ConversantSampleApp
//
//  Created by Jeff Carlson on 3/7/14.
//  Copyright (c) 2014 Conversant. All rights reserved.
//

#import "iPadViewController.h"

#import <AdSupport/ASIdentifierManager.h>
#import "AppDelegate.h"
#import "GSAdDelegate.h"
#import "GSLeaderboardAdView.h"
#import "GSMediumRectangleAdView.h"
#import "GSFullscreenAd.h"
#import "GSSDKInfo.h"
#import <MessageUI/MessageUI.h>

@interface iPadViewController () <GSAdDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) GSFullscreenAd *myFullscreenAd;
@property (nonatomic, strong) GSLeaderboardAdView *myLeaderboardAd;
@property (nonatomic, strong) GSMediumRectangleAdView *myMediumRectangleAd;

@property (nonatomic, weak) IBOutlet UILabel *advertisingId;
@property (nonatomic, weak) IBOutlet UILabel *appIdLabel;
@property (nonatomic, weak) IBOutlet UILabel *appIdTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *sdkVersionLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIButton *displayFullscreenButton;
@property (nonatomic, weak) IBOutlet UIButton *fetchFullscreenButton;
@property (nonatomic, weak) IBOutlet UIButton *leaderboardButton;
@property (nonatomic, weak) IBOutlet UIButton *mediumRectangleButton;

@end

@implementation iPadViewController

#pragma mark - UIViewController -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Grab the Conversant App ID and add to label
    self.appIdLabel.text = APPID;
    
    //Labels the Test GUID
    NSString *testAPPID = [NSString stringWithFormat:@"51d7ee3c-95fd-48d5-b648-c915209a00a5"];
    if( [APPID isEqualToString:testAPPID] )
    {
        self.appIdTitleLabel.text = [NSString stringWithFormat:@"Conversant Test App ID"];
    }
    
    //Put an initial status into the status box
    if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
    {
        self.advertisingId.text = @"Not Supported on iOS 5 or below";
    }
    else
    {
        self.advertisingId.text = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    //NSLog(@"%f",[[[UIDevice currentDevice] systemVersion] floatValue]);
    
    //Populate SDK version and GS Device ID labels
    self.sdkVersionLabel.text = [NSString stringWithFormat:@"iOS %@", kGSSDKVersion];
    
    //Populate SDK version and GS Device ID labels
    self.sdkVersionLabel.text = [NSString stringWithFormat:@"iOS %@", kGSSDKVersion];
    
    self.myMediumRectangleAd = [[GSMediumRectangleAdView alloc] initWithDelegate:self];
    
    [self.myMediumRectangleAd setFrame:CGRectMake(([self.view bounds].size.width - kGSMediumRectangleWidth)/2, 20, kGSMediumRectangleWidth, kGSMediumRectangleHeight)];
    
    self.myLeaderboardAd = [[GSLeaderboardAdView alloc] initWithDelegate:self];
    
    [self.myLeaderboardAd setFrame:CGRectMake(([self.view bounds].size.width - kGSLeaderboardWidth)/2, 524, kGSLeaderboardWidth, kGSLeaderboardHeight)];
    
    //Init my fullscren ad object, and set the delegate to be this ViewController
    self.myFullscreenAd = [[GSFullscreenAd alloc] initWithDelegate:self];
}

#pragma mark - Conversant UIViewController -

- (UIViewController *)greystripeBannerDisplayViewController
{
    return self;
}

#pragma mark - IBAction Buttons -

- (IBAction)mediumRectangleButtonPressed:(id)sender
{
    self.statusLabel.text = @"Fetching an ad...";
    [self.mediumRectangleButton setEnabled:NO];
    
    // Fetch Medium Rectangle Ad
    [self.myMediumRectangleAd fetch];
}

- (IBAction)leaderboardButtonPressed:(id)sender
{
    self.statusLabel.text = @"Fetching an ad...";
    [self.leaderboardButton setEnabled:NO];
    
    // Fetch Leaderboard Ad
    [self.myLeaderboardAd fetch];
}

- (IBAction)fetchFullscreenButtonPressed:(id)sender
{
    self.statusLabel.text = @"Fetching an ad...";
    [self.fetchFullscreenButton setEnabled:NO];
    
    // Fetch Fullscreen Ad
    [self.myFullscreenAd fetch];
}

- (IBAction)displayFullscreenButtonPressed:(id)sender
{
    self.statusLabel.text = @"Display Fullscreen Ad.";
    
    // Display Fullscreen Ad
    [self.myFullscreenAd displayFromViewController:self];
    
    [self.displayFullscreenButton setEnabled:NO];
    [self.fetchFullscreenButton setEnabled:YES];
}

- (IBAction)openMail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"Conversant iOS %@ SDK Info", kGSSDKVersion]];
        NSString *emailBody = [NSString stringWithFormat:@"<p><b>Device Id:</b> %@ </p><p><b>Conversant SDK Version:</b> iOS %@</p><p><b>Conversant GUID:</b> %@</p><p><b>Documentation Resources:</b> <a href=\"http://support.greystripe.com\">http://support.greystripe.com</a></p><p><b>Questions? Contact GS Support:</b> <a href=\"mailto:support_mobile@conversantmedia.com\">support_mobile@conversantmedia.com</a></p>", [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString], kGSSDKVersion, APPID];
        [mailer setMessageBody:emailBody isHTML:YES];
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Conversant Protocol Methods -


- (BOOL)greystripeBannerAutoload
{
    // Return TRUE to autoload an ad
    return FALSE;
}

- (BOOL)greystripeShouldLogAdID
{
    // Return TRUE to log the AdID in an NSLog. Useful for debugging purposes.
    return FALSE;
}

- (void)greystripeAdFetchSucceeded:(id<GSAd>)a_ad
{
    if (a_ad == self.myLeaderboardAd)
    {
        [self.view addSubview:self.myLeaderboardAd];
        
        self.statusLabel.text = @"Leaderboard Ad successfully fetched.";
        [self.leaderboardButton setEnabled:YES];
    }
    else if (a_ad == self.myMediumRectangleAd)
    {
        [self.view addSubview:self.myMediumRectangleAd];
        
        self.statusLabel.text = @"Medium Rectangle Ad successfully fetched.";
        [self.mediumRectangleButton setEnabled:YES];
    }
    else if (a_ad == self.myFullscreenAd)
    {
        self.statusLabel.text = @"Fullscreen Ad successfully fetched.";
        [self.displayFullscreenButton setEnabled:YES];
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
    [self.mediumRectangleButton setEnabled:YES];
    [self.fetchFullscreenButton setEnabled:YES];
    [self.leaderboardButton setEnabled:YES];
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

#pragma mark - MFMailComposeViewController -

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Banner Rotation Management -

- (void) viewWillLayoutSubviews
{
    [self.myMediumRectangleAd setFrame:CGRectMake(([self.view bounds].size.width - kGSMediumRectangleWidth)/2, 20, kGSMediumRectangleWidth, kGSMediumRectangleHeight)];
    
    [self.myLeaderboardAd setFrame:CGRectMake(([self.view bounds].size.width - kGSLeaderboardWidth)/2, 524, kGSLeaderboardWidth, kGSLeaderboardHeight)];
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
