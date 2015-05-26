//
//  MobFoxNativeFormatInterstitial.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 05.05.2015.
//
//

#import "MobFoxNativeFormatInterstitial.h"
#import "MobFoxCreativesQueueManager.h"
#import "MobFoxNativeFormatCreativesManager.h"
#import "MobFoxNativeFormatView.h"
#import "MobFoxVideoInterstitialViewController.h"
#import "MobFoxInterstitialPlayerViewController.h"
#import "UIImage+MobFox.h"

@interface MobFoxNativeFormatInterstitial ()<MobFoxNativeFormatViewDelegate>{
    UIInterfaceOrientation requestedAdOrientation;
    float buttonSize;
    BOOL adLoaded;
}

@property (nonatomic, strong) MobFoxNativeFormatCreativesManager* nativeFormatCreativesManager;
@property (nonatomic, strong) MobFoxInterstitialPlayerViewController *mobFoxInterstitialPlayerViewController;
@property (nonatomic, strong) UIView *interstitialHoldingView;
@property (nonatomic, strong) UIButton *interstitialSkipButton;
@property (nonatomic, strong) UIViewController* viewController;

@end

@implementation MobFoxNativeFormatInterstitial

-(instancetype)initWithPublisherId:(NSString*)publisherId {
    self = [super init];
    [self setupWithPublisherId:publisherId];
    return self;
}

-(void)dealloc {
    self.nativeFormatCreativesManager = nil;
    self.mobFoxInterstitialPlayerViewController = nil;
    self.interstitialHoldingView = nil;
    self.delegate = nil;
    self.interstitialSkipButton = nil;
    self.viewController = nil;
}

- (void)setupWithPublisherId:(NSString*)publisherId {

    self.nativeFormatCreativesManager = [MobFoxNativeFormatCreativesManager sharedManagerWithPublisherId:publisherId];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        buttonSize = 40.0f;
    }
    else
    {
        buttonSize = 50.0f;
    }
}


-(void) requestAdWithPublisherId:(NSString *)publisherId andViewController:(UIViewController*)controller {
    
    adLoaded = NO;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    requestedAdOrientation = interfaceOrientation;
    self.viewController = controller;
    
    [self prepareInterstitialView];
    
    NSInteger width, height;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            width = 320;
            height = 480;
        } else {
            width = 480;
            height = 320;
        }
    }
    else
    {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            width = 768;
            height = 1024;
        } else {
            width = 1024;
            height = 768;
        }
    }
    
    
    MobFoxNativeFormatCreative* chosenCreative = [self.nativeFormatCreativesManager getCreativeWithWidth:width andHeight:height];
    if (!chosenCreative) {
        NSString* errorString = [NSString stringWithFormat:@"Cannot find creative template for requested size: %li x %li", (long)width, (long)height];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
        NSError* error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:0 userInfo:userInfo];
        [self.delegate mobfoxNativeFormatInterstitialDidFailToLoadWithError:error];
        return;
    }
    MobFoxNativeFormatView* nativeFormatView = [[MobFoxNativeFormatView alloc]init];
    nativeFormatView.delegate = self;
    [nativeFormatView requestAdWithCreative:chosenCreative andPublisherId:publisherId];
    
    [self createInterstitialFromView:nativeFormatView];
    
}

- (void) prepareInterstitialView {
    
    self.mobFoxInterstitialPlayerViewController = [[MobFoxInterstitialPlayerViewController alloc] init];
    
    NSString* adInterstitialOrientation;
    if(UIInterfaceOrientationIsPortrait(requestedAdOrientation))
    {
        adInterstitialOrientation = @"portrait";
    }
    else
    {
        adInterstitialOrientation = @"landscape";
    }
    
    self.mobFoxInterstitialPlayerViewController.adInterstitialOrientation = adInterstitialOrientation;
    self.mobFoxInterstitialPlayerViewController.view.backgroundColor = [UIColor clearColor];
    self.mobFoxInterstitialPlayerViewController.view.frame = self.viewController.view.bounds;
    self.interstitialHoldingView = [[UIView alloc] initWithFrame:self.viewController.view.bounds];
    self.interstitialHoldingView.backgroundColor = [UIColor clearColor];
    self.interstitialHoldingView.autoresizesSubviews = YES;
}

- (void) createInterstitialFromView:(UIView*)view {
    
    [self.interstitialHoldingView addSubview:view];
    
    view.center = self.interstitialHoldingView.center;
    
    UIImage *buttonImage = [UIImage mobfoxSkipButtonImage];
    UIImage *buttonDisabledImage = buttonDisabledImage = [UIImage mobfoxSkipButtonDisabledImage];
    
    float skipButtonSize = buttonSize + 4.0f;
    
    self.interstitialSkipButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.interstitialSkipButton setFrame:CGRectMake(0, 0, skipButtonSize, skipButtonSize)];
    [self.interstitialSkipButton addTarget:self action:@selector(interstitialSkipAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.interstitialSkipButton setImage:buttonImage forState:UIControlStateNormal];
    [self.interstitialSkipButton setImage:buttonDisabledImage forState:UIControlStateHighlighted];
    
    self.interstitialSkipButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self showInterstitialSkipButton];
}

- (void)showInterstitialSkipButton {
    
    float skipButtonSize = buttonSize + 4.0f;
    CGRect buttonFrame = self.interstitialSkipButton.frame;
    buttonFrame.origin.x = self.viewController.view.frame.size.width - (skipButtonSize+10.0f);
    buttonFrame.origin.y = 10.0f;
    
    self.interstitialSkipButton.frame = buttonFrame;
    
    [self.interstitialHoldingView addSubview:self.interstitialSkipButton];
    
}

-(void)showAd {
    if(!adLoaded) {
        return;
    }
    
    [self.delegate mobfoxNativeFormatInterstitialWillPresent];
    [self.mobFoxInterstitialPlayerViewController.view addSubview:self.interstitialHoldingView];
    
    self.viewController.wantsFullScreenLayout = YES;
    
    [self.viewController presentModalViewController:self.mobFoxInterstitialPlayerViewController animated:NO];
    
}

- (void)mobfoxNativeFormatDidLoad:(MobFoxNativeFormatView *)nativeFormatView {
    adLoaded = YES;
    [self.delegate mobfoxNativeFormatInterstitialDidLoad];
}

- (void)mobfoxNativeFormatDidFailToLoadWithError:(NSError *)error {
    [self.delegate mobfoxNativeFormatInterstitialDidFailToLoadWithError:error];
}

- (void)interstitialSkipAction:(id)sender {
    [self.delegate mobfoxNativeFormatInterstitialActionWillFinish];
    [self.viewController dismissModalViewControllerAnimated:NO];
    self.viewController = nil;
}







@end
