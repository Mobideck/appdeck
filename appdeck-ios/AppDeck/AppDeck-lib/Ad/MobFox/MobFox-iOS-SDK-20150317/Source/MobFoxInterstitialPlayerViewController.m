

#import "MobFoxInterstitialPlayerViewController.h"

@interface MobFoxInterstitialPlayerViewController ()

@end

@implementation MobFoxInterstitialPlayerViewController

@synthesize adInterstitialOrientation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    self.wantsFullScreenLayout = YES;

}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIApplication *app = [UIApplication sharedApplication];
    [app setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    if ([adInterstitialOrientation isEqualToString:@"landscape"] || [adInterstitialOrientation isEqualToString:@"Landscape"]) {
        return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
    }

    if ([adInterstitialOrientation isEqualToString:@"Portrait"] || [adInterstitialOrientation isEqualToString:@"portrait"]) {
        return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
    }

    return NO;
}

-(BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    UIApplication *app = [UIApplication sharedApplication];
    [app setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    if ([adInterstitialOrientation isEqualToString:@"landscape"] || [adInterstitialOrientation isEqualToString:@"Landscape"]) {
        return UIInterfaceOrientationMaskLandscape;
    }

    if ([adInterstitialOrientation isEqualToString:@"Portrait"] || [adInterstitialOrientation isEqualToString:@"portrait"]) {
        return UIInterfaceOrientationMaskPortrait;
    }

    return UIInterfaceOrientationMaskAll;
}


@end
