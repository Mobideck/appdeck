//
//  MPAdDestinationDisplayAgent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPURLResolverMF.h"
#import "MPProgressOverlayViewMF.h"
#import "MPAdBrowserControllerMF.h"
#import "MPStoreKitProviderMF.h"

@protocol MPAdDestinationDisplayAgentDelegateMF;

@interface MPAdDestinationDisplayAgentMF : NSObject <MPURLResolverDelegateMF, MPProgressOverlayViewDelegateMF, MPAdBrowserControllerDelegateMF, MPSKStoreProductViewControllerDelegate>

@property (nonatomic, assign) id<MPAdDestinationDisplayAgentDelegateMF> delegate;

+ (MPAdDestinationDisplayAgentMF *)agentWithDelegate:(id<MPAdDestinationDisplayAgentDelegateMF>)delegate;
- (void)displayDestinationForURL:(NSURL *)URL;
- (void)cancel;

@end

@protocol MPAdDestinationDisplayAgentDelegateMF <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;
- (void)displayAgentWillPresentModal;
- (void)displayAgentWillLeaveApplication;
- (void)displayAgentDidDismissModal;

@end
