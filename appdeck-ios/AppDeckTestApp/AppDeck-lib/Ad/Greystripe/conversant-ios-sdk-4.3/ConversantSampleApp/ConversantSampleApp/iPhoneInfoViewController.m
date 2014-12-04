//
//  iPhoneInfoViewController.m
//  ConversantSampleApp
//
//  Created by Jeff Carlson on 5/12/14.
//  Copyright (c) 2014 Conversant. All rights reserved.
//

#import "iPhoneInfoViewController.h"

@interface iPhoneInfoViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *advertisingId;
@property (nonatomic, weak) IBOutlet UILabel *appIdLabel;
@property (nonatomic, weak) IBOutlet UILabel *appIdTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *sdkVersionLabel;

@end

@implementation iPhoneInfoViewController

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
}

#pragma mark - IBAction Button -

- (IBAction)openMail:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"Conversant iOS %@ SDK Info", kGSSDKVersion]];
        NSString *emailBody = [NSString stringWithFormat:@"<p><b>Device Id:</b> %@ </p><p><b>Conversant SDK Version:</b> iOS %@</p><p><b>Conversant GUID:</b> %@</p><p><b>Documentation Resources:</b> <a href=\"http://support.greystripe.com\">http://support.greystripe.com</a></p><p><b>Questions? Contact GS Support:</b> <a href=\"mailto:support_mobile@conversantmedia.com\">support_mobile@conversantmedia.com</a></p>", [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString], kGSSDKVersion, APPID];
        [mailer setMessageBody:emailBody isHTML:YES];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
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

#pragma mark - Memory Management -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Used for demo app presentation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end
