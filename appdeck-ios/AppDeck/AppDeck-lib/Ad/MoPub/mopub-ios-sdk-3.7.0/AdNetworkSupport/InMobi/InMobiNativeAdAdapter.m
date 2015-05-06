//
//  InMobiNativeAdAdapter.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "InMobiNativeAdAdapter.h"
#import "IMNative.h"
#import "MPNativeAdError.h"
#import "MPNativeAdConstants.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPCoreInstanceProvider.h"
#import "MPLogging.h"

/*
 * Default keys for InMobi Native Ads
 *
 * These values must correspond to the strings configured with InMobi.
 */
static NSString *gInMobiTitleKey = @"title";
static NSString *gInMobiDescriptionKey = @"description";
static NSString *gInMobiCallToActionKey = @"cta";
static NSString *gInMobiRatingKey = @"rating";
static NSString *gInMobiScreenshotKey = @"screenshots";
static NSString *gInMobiIconKey = @"icon";
// As of 6-25-2014 this key is editable on InMobi's site
static NSString *gInMobiLandingURLKey = @"landing_url";

/*
 * InMobi Key - Do Not Change.
 */
static NSString *const kInMobiImageURL = @"url";

@interface InMobiNativeAdAdapter() <MPAdDestinationDisplayAgentDelegate>

@property (nonatomic, readonly, strong) IMNative *inMobiNativeAd;

@property (nonatomic, readonly, strong) MPAdDestinationDisplayAgent *destinationDisplayAgent;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, copy) void (^actionCompletionBlock)(BOOL, NSError *);

@end

@implementation InMobiNativeAdAdapter

@synthesize properties = _properties;
@synthesize defaultActionURL = _defaultActionURL;

+ (void)setCustomKeyForTitle:(NSString *)key
{
    gInMobiTitleKey = [key copy];
}

+ (void)setCustomKeyForDescription:(NSString *)key
{
    gInMobiDescriptionKey = [key copy];
}

+ (void)setCustomKeyForCallToAction:(NSString *)key
{
    gInMobiCallToActionKey = [key copy];
}

+ (void)setCustomKeyForRating:(NSString *)key
{
    gInMobiRatingKey = [key copy];
}

+ (void)setCustomKeyForScreenshot:(NSString *)key
{
    gInMobiScreenshotKey = [key copy];
}

+ (void)setCustomKeyForIcon:(NSString *)key
{
    gInMobiIconKey = [key copy];
}

+ (void)setCustomKeyForLandingURL:(NSString *)key
{
    gInMobiLandingURLKey = [key copy];
}

- (instancetype)initWithInMobiNativeAd:(IMNative *)nativeAd
{
    self = [super init];
    if (self) {
        _inMobiNativeAd = nativeAd;

        NSDictionary *inMobiProperties = [self inMobiProperties];
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];

        if ([inMobiProperties objectForKey:gInMobiRatingKey]) {
            [properties setObject:[inMobiProperties objectForKey:gInMobiRatingKey] forKey:kAdStarRatingKey];
        }

        if ([[inMobiProperties objectForKey:gInMobiTitleKey] length]) {
            [properties setObject:[inMobiProperties objectForKey:gInMobiTitleKey] forKey:kAdTitleKey];
        }

        if ([[inMobiProperties objectForKey:gInMobiDescriptionKey] length]) {
            [properties setObject:[inMobiProperties objectForKey:gInMobiDescriptionKey] forKey:kAdTextKey];
        }

        if ([[inMobiProperties objectForKey:gInMobiCallToActionKey] length]) {
            [properties setObject:[inMobiProperties objectForKey:gInMobiCallToActionKey] forKey:kAdCTATextKey];
        }

        NSDictionary *iconDictionary = [inMobiProperties objectForKey:gInMobiIconKey];

        if ([[iconDictionary objectForKey:kInMobiImageURL] length]) {
            [properties setObject:[iconDictionary objectForKey:kInMobiImageURL] forKey:kAdIconImageKey];
        }

        NSDictionary *mainImageDictionary = [inMobiProperties objectForKey:gInMobiScreenshotKey];

        if ([[mainImageDictionary objectForKey:kInMobiImageURL] length]) {
            [properties setObject:[mainImageDictionary objectForKey:kInMobiImageURL] forKey:kAdMainImageKey];
        }

        _properties = properties;

        if ([[inMobiProperties objectForKey:gInMobiLandingURLKey] length]) {
            _defaultActionURL = [NSURL URLWithString:[inMobiProperties objectForKey:gInMobiLandingURLKey]];
        } else {
            // Log a warning if we can't find the landing URL since the key can either be "landing_url", "landingURL", or a custom key depending on the date the property was created.
            MPLogWarn(@"WARNING: Couldn't find landing url with key: %@ for InMobi network.  Double check your ad property and call setCustomKeyForLandingURL: with the correct key if necessary.", gInMobiLandingURLKey);
        }

        _destinationDisplayAgent = [[MPCoreInstanceProvider sharedProvider] buildMPAdDestinationDisplayAgentWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_destinationDisplayAgent cancel];
    [_destinationDisplayAgent setDelegate:nil];
}

- (NSDictionary *)inMobiProperties
{
    NSData *data = [self.inMobiNativeAd.content dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSDictionary *propertyDictionary = nil;
    if (data) {
        propertyDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    if (propertyDictionary && !error) {
        return propertyDictionary;
    }
    else {
        return nil;
    }
}

#pragma mark - MPNativeAdAdapter

- (NSTimeInterval)requiredSecondsForImpression
{
    return 0.0;
}

- (void)willAttachToView:(UIView *)view
{
    [self.inMobiNativeAd attachToView:view];
}

- (void)trackClick
{
    [self.inMobiNativeAd handleClick:nil];
}

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller
                  completion:(void (^)(BOOL success, NSError *error))completionBlock
{
    NSError *error = nil;

    if (!controller) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Cannot display content without a root view controller."
                                                             forKey:MPNativeAdErrorContentDisplayErrorReasonKey];
        error = [NSError errorWithDomain:MoPubNativeAdsSDKDomain
                                    code:MPNativeAdErrorContentDisplayError
                                userInfo:userInfo];
    }

    if (!URL || ![URL isKindOfClass:[NSURL class]] || ![URL.absoluteString length]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Cannot display content without a valid URL."
                                                             forKey:MPNativeAdErrorContentDisplayErrorReasonKey];
        error = [NSError errorWithDomain:MoPubNativeAdsSDKDomain
                                    code:MPNativeAdErrorContentDisplayError
                                userInfo:userInfo];
    }

    if (error) {

        if (completionBlock) {
            completionBlock(NO, error);
        }
        return;
    }

    self.rootViewController = controller;
    self.actionCompletionBlock = completionBlock;

    [self.destinationDisplayAgent displayDestinationForURL:URL];
}

#pragma mark - <MPAdDestinationDisplayAgent>

- (UIViewController *)viewControllerForPresentingModalView
{
    return self.rootViewController;
}

- (void)displayAgentWillPresentModal
{

}

- (void)displayAgentWillLeaveApplication
{
    if (self.actionCompletionBlock) {
        self.actionCompletionBlock(YES, nil);
        self.actionCompletionBlock = nil;
    }
}

- (void)displayAgentDidDismissModal
{
    if (self.actionCompletionBlock) {
        self.actionCompletionBlock(YES, nil);
        self.actionCompletionBlock = nil;
    }
    self.rootViewController = nil;
}


@end
