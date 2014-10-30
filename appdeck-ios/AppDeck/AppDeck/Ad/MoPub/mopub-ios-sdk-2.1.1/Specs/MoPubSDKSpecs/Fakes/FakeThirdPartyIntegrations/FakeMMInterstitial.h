//
//  FakeMMInterstitial.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MillennialMedia/MMSDK.h>

@class MMAdView;
@protocol MMAdDelegate;

@interface FakeMMInterstitial : NSObject <FakeInterstitialAd>

@property (nonatomic, assign) NSMutableDictionary *requests;
@property (nonatomic, assign) NSMutableDictionary *fetchCompletionBlocks;

@property (nonatomic, assign) NSMutableDictionary *viewControllers;
@property (nonatomic, assign) NSMutableDictionary *overlayOrientations;
@property (nonatomic, assign) NSMutableDictionary *displayCompletionBlocks;

- (void)reset;

- (void)setAvailabilityOfApid:(NSString *)apid to:(BOOL)availability;

- (NSDictionary *)userInfoForAPID:(NSString *)apid;

- (void)simulateSuccesfulPresentation:(NSString *)apid;
- (void)simulateFailedPresentation:(NSString *)apid;
- (void)simulateDismissingAd:(NSString *)apid;

- (void)simulateInterstitialTap; //Millennial's tap events aren't scoped by ApID

- (MMCompletionBlock)fetchCompletionBlock:(NSString *)apid;

- (void)simulateInterstitialWillAppear:(NSString *)apid;
- (void)simulateInterstitialDidAppear:(NSString *)apid;
- (void)simulateInterstitialWillDismiss:(NSString *)apid;
- (void)simulateInterstitialDidDismiss:(NSString *)apid;


@end
