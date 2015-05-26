//
//  MPAdDestinationDisplayAgent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdDestinationDisplayAgentMF.h"
#import "UIViewController+MPAdditionsMF.h"
#import "MPCoreInstanceProviderMF.h"
#import "MPLastResortDelegateMF.h"
#import "NSURL+MPAdditionsMF.h"

@interface MPAdDestinationDisplayAgentMF ()

@property (nonatomic, retain) MPURLResolverMF *resolver;
@property (nonatomic, retain) MPProgressOverlayViewMF *overlayView;
@property (nonatomic, assign) BOOL isLoadingDestination;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
@property (nonatomic, retain) SKStoreProductViewController *storeKitController;
#endif

@property (nonatomic, retain) MPAdBrowserControllerMF *browserController;
@property (nonatomic, retain) MPTelephoneConfirmationControllerMF *telephoneConfirmationController;

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier fallbackURL:(NSURL *)URL;
- (void)hideOverlay;
- (void)hideModalAndNotifyDelegate;
- (void)dismissAllModalContent;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPAdDestinationDisplayAgentMF

@synthesize delegate = _delegate;
@synthesize resolver = _resolver;
@synthesize isLoadingDestination = _isLoadingDestination;

+ (MPAdDestinationDisplayAgentMF *)agentWithDelegate:(id<MPAdDestinationDisplayAgentDelegateMF>)delegate
{
    MPAdDestinationDisplayAgentMF *agent = [[[MPAdDestinationDisplayAgentMF alloc] init] autorelease];
    agent.delegate = delegate;
    agent.resolver = [[MPCoreInstanceProviderMF sharedProvider] buildMPURLResolver];
    agent.overlayView = [[[MPProgressOverlayViewMF alloc] initWithDelegate:agent] autorelease];
    return agent;
}

- (void)dealloc
{
    [self dismissAllModalContent];

    self.telephoneConfirmationController = nil;
    self.overlayView.delegate = nil;
    self.overlayView = nil;
    self.resolver.delegate = nil;
    self.resolver = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
    // XXX: If this display agent is deallocated while a StoreKit controller is still on-screen,
    // nil-ing out the controller's delegate would leave us with no way to dismiss the controller
    // in the future. Therefore, we change the controller's delegate to a singleton object which
    // implements SKStoreProductViewControllerDelegate and is always around.
    self.storeKitController.delegate = [MPLastResortDelegateMF sharedDelegate];
    self.storeKitController = nil;
#endif
    self.browserController.delegate = nil;
    self.browserController = nil;

    [super dealloc];
}

- (void)dismissAllModalContent
{
    [self.overlayView hide];
}

- (void)displayDestinationForURL:(NSURL *)URL
{
    if (self.isLoadingDestination) return;
    self.isLoadingDestination = YES;

    [self.delegate displayAgentWillPresentModal];
    [self.overlayView show];

    [self.resolver startResolvingWithURL:URL delegate:self];
}

- (void)cancel
{
    if (self.isLoadingDestination) {
        self.isLoadingDestination = NO;
        [self.resolver cancel];
        [self hideOverlay];
        [self.delegate displayAgentDidDismissModal];
    }
}

#pragma mark - <MPURLResolverDelegate>

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL
{
    [self hideOverlay];

    self.browserController = [[[MPAdBrowserControllerMF alloc] initWithURL:URL
                                                              HTMLString:HTMLString
                                                                delegate:self] autorelease];
    self.browserController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[self.delegate viewControllerForPresentingModalView] mp_presentModalViewController:self.browserController
                                                                               animated:MP_ANIMATED];
}

- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL
{
    if ([MPStoreKitProviderMF deviceHasStoreKit]) {
        [self presentStoreKitControllerWithItemIdentifier:parameter fallbackURL:URL];
    } else {
        [self openURLInApplication:URL];
    }
}

- (void)openURLInApplication:(NSURL *)URL
{
    [self hideOverlay];

    if ([URL mp_hasTelephoneScheme] || [URL mp_hasTelephonePromptScheme]) {
        [self interceptTelephoneURL:URL];
    } else {
        [self.delegate displayAgentWillLeaveApplication];
        [[UIApplication sharedApplication] openURL:URL];
        self.isLoadingDestination = NO;
    }
}

- (void)interceptTelephoneURL:(NSURL *)URL
{
    __block MPAdDestinationDisplayAgentMF *blockSelf = self;
    self.telephoneConfirmationController = [[[MPTelephoneConfirmationControllerMF alloc] initWithURL:URL clickHandler:^(NSURL *targetTelephoneURL, BOOL confirmed) {
        if (confirmed) {
            [blockSelf.delegate displayAgentWillLeaveApplication];
            [[UIApplication sharedApplication] openURL:targetTelephoneURL];
        }
        blockSelf.isLoadingDestination = NO;
        [blockSelf.delegate displayAgentDidDismissModal];
    }] autorelease];

    [self.telephoneConfirmationController show];
}

- (void)failedToResolveURLWithError:(NSError *)error
{
    self.isLoadingDestination = NO;
    [self hideOverlay];
    [self.delegate displayAgentDidDismissModal];
}

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier fallbackURL:(NSURL *)URL
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
    self.storeKitController = [MPStoreKitProviderMF buildController];
    self.storeKitController.delegate = self;

    NSDictionary *parameters = [NSDictionary dictionaryWithObject:identifier
                                                           forKey:SKStoreProductParameterITunesItemIdentifier];
    [self.storeKitController loadProductWithParameters:parameters completionBlock:nil];

    [self hideOverlay];
    [[self.delegate viewControllerForPresentingModalView] mp_presentModalViewController:self.storeKitController
                                                                               animated:MP_ANIMATED];
#endif
}

#pragma mark - <MPSKStoreProductViewControllerDelegate>
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    self.isLoadingDestination = NO;
    [self hideModalAndNotifyDelegate];
}

#pragma mark - <MPAdBrowserControllerDelegate>
- (void)dismissBrowserController:(MPAdBrowserControllerMF *)browserController animated:(BOOL)animated
{
    self.isLoadingDestination = NO;
    [self hideModalAndNotifyDelegate];
}

#pragma mark - <MPProgressOverlayViewDelegate>
- (void)overlayCancelButtonPressed
{
    [self cancel];
}

#pragma mark - Convenience Methods
- (void)hideModalAndNotifyDelegate
{
    [[self.delegate viewControllerForPresentingModalView] mp_dismissModalViewControllerAnimated:MP_ANIMATED];
    [self.delegate displayAgentDidDismissModal];
}

- (void)hideOverlay
{
    [self.overlayView hide];
}

@end
