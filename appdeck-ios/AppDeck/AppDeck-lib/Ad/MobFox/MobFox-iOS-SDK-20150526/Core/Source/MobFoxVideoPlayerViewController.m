

#import "MobFoxVideoPlayerViewController.h"

@interface MobFoxVideoPlayerViewController ()

@end

@implementation MobFoxVideoPlayerViewController

@synthesize adVideoOrientation;

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

    if ([adVideoOrientation isEqualToString:@"landscape"] || [adVideoOrientation isEqualToString:@"Landscape"]) {
        return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
    }

    if ([adVideoOrientation isEqualToString:@"Portrait"] || [adVideoOrientation isEqualToString:@"portrait"]) {
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

    if ([adVideoOrientation isEqualToString:@"landscape"] || [adVideoOrientation isEqualToString:@"Landscape"]) {
        return UIInterfaceOrientationMaskLandscape;
    }

    if ([adVideoOrientation isEqualToString:@"Portrait"] || [adVideoOrientation isEqualToString:@"portrait"]) {
        return UIInterfaceOrientationMaskPortrait;
    }

    return UIInterfaceOrientationMaskAll;
}

@end
