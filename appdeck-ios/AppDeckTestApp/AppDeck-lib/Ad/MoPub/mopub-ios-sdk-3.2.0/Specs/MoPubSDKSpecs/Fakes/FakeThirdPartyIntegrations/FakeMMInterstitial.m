//
//  FakeMMInterstitialAdView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMMInterstitial.h"

@interface FakeMMInterstitial ()

@property (nonatomic, strong) NSMutableDictionary *availability;

@end

@implementation FakeMMInterstitial

- (id)init
{
    self = [super init];

    if (self) {
        self.requests = [NSMutableDictionary dictionary];
        self.fetchCompletionBlocks = [NSMutableDictionary dictionary];
        self.viewControllers = [NSMutableDictionary dictionary];
        self.overlayOrientations = [NSMutableDictionary dictionary];
        self.displayCompletionBlocks = [NSMutableDictionary dictionary];
        self.availability = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)reset
{
    self.requests = [NSMutableDictionary dictionary];
    self.fetchCompletionBlocks = [NSMutableDictionary dictionary];
    self.viewControllers = [NSMutableDictionary dictionary];
    self.overlayOrientations = [NSMutableDictionary dictionary];
    self.displayCompletionBlocks = [NSMutableDictionary dictionary];
    self.availability = [NSMutableDictionary dictionary];
}

- (UIViewController *)presentingViewController
{
    return [self.viewControllers.allValues lastObject]; //any view controller
}

- (NSDictionary *)userInfoForAPID:(NSString *)apid
{
    return @{MillennialMediaAdTypeKey: MillennialMediaAdTypeInterstitial, MillennialMediaAPIDKey: apid};
}

- (void)setAvailabilityOfApid:(NSString *)apid to:(BOOL)availability
{
    self.availability[apid] = @(availability);
}

- (void)fetchWithRequest:(MMRequest *)request
                    apid:(NSString *)apid
            onCompletion:(MMCompletionBlock)callback
{
    self.requests[apid] = request;
    self.fetchCompletionBlocks[apid] = [callback copy];
}

- (BOOL)isAdAvailableForApid:(NSString *)apid
{
    return [self.availability[apid] boolValue];
}

- (void)displayForApid:(NSString *)apid
    fromViewController:(UIViewController *)viewController
       withOrientation:(UIInterfaceOrientation)overlayOrientation
          onCompletion:(MMCompletionBlock)callback;
{
    self.viewControllers[apid] = viewController;
    self.overlayOrientations[apid] = @(overlayOrientation);
    self.displayCompletionBlocks[apid] = [callback copy];
}

- (void)simulateSuccesfulPresentation:(NSString *)apid
{
    [self displayCompletionBlock:apid](YES, nil);
    [self simulateInterstitialWillAppear:apid];
    [self simulateInterstitialDidAppear:apid];
}

- (void)simulateFailedPresentation:(NSString *)apid
{
    [self displayCompletionBlock:apid](NO, nil);
}

- (void)simulateDismissingAd:(NSString *)apid
{
    [self simulateInterstitialWillDismiss:apid];
    [self simulateInterstitialDidDismiss:apid];
}


- (void)simulateInterstitialWillAppear:(NSString *)apid
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalWillAppear object:nil userInfo:[self userInfoForAPID:apid]];
}

- (void)simulateInterstitialDidAppear:(NSString *)apid
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalDidAppear object:nil userInfo:[self userInfoForAPID:apid]];
}

- (void)simulateInterstitialWillDismiss:(NSString *)apid
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalWillDismiss object:nil userInfo:[self userInfoForAPID:apid]];
}

- (void)simulateInterstitialDidDismiss:(NSString *)apid
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalDidDismiss object:nil userInfo:[self userInfoForAPID:apid]];
}

- (void)simulateInterstitialTap
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWasTapped object:nil userInfo: @{MillennialMediaAdTypeKey: MillennialMediaAdTypeInterstitial}];
}

- (MMCompletionBlock)fetchCompletionBlock:(NSString *)apid
{
    return self.fetchCompletionBlocks[apid];
}

- (MMCompletionBlock)displayCompletionBlock:(NSString *)apid
{
    return self.displayCompletionBlocks[apid];
}

@end
