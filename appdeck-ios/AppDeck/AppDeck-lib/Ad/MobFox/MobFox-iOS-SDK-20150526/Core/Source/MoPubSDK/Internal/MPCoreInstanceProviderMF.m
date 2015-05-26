//
//  MPCoreInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPCoreInstanceProviderMF.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "MPAdServerCommunicatorMF.h"
#import "MPURLResolverMF.h"
#import "MPAdDestinationDisplayAgentMF.h"
#import "MPReachabilityMF.h"
#import "MPTimerMF.h"
#import "MPAnalyticsTrackerMF.h"


#define MOPUB_CARRIER_INFO_DEFAULTS_KEY @"com.mopub.carrierinfo"


typedef enum
{
    MPTwitterDeepLinkNotChecked,
    MPTwitterDeepLinkEnabled,
    MPTwitterDeepLinkDisabled
} MPTwitterDeepLink;

@interface MPCoreInstanceProviderMF ()

@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, retain) NSMutableDictionary *singletons;
@property (nonatomic, retain) NSMutableDictionary *carrierInfo;
@property (nonatomic, assign) MPTwitterDeepLink twitterDeepLinkStatus;

@end

@implementation MPCoreInstanceProviderMF

@synthesize userAgent = _userAgent;
@synthesize singletons = _singletons;
@synthesize carrierInfo = _carrierInfo;
@synthesize twitterDeepLinkStatus = _twitterDeepLinkStatus;

static MPCoreInstanceProviderMF *sharedProvider = nil;

+ (instancetype)sharedProvider
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedProvider = [[self alloc] init];
    });
    
    return sharedProvider;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.singletons = [NSMutableDictionary dictionary];
        
        [self initializeCarrierInfo];
    }
    return self;
}

- (void)dealloc
{
    self.singletons = nil;
    self.carrierInfo = nil;
    [super dealloc];
}

- (id)singletonForClass:(Class)klass provider:(MPSingletonProviderBlock)provider
{
    id singleton = [self.singletons objectForKey:klass];
    if (!singleton) {
        singleton = provider();
        [self.singletons setObject:singleton forKey:(id<NSCopying>)klass];
    }
    return singleton;
}

#pragma mark - Initializing Carrier Info

- (void)initializeCarrierInfo
{
    self.carrierInfo = [NSMutableDictionary dictionary];
    
    // check if we have a saved copy
    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:MOPUB_CARRIER_INFO_DEFAULTS_KEY];
    if(saved != nil) {
        [self.carrierInfo addEntriesFromDictionary:saved];
    }
    
    // now asynchronously load a fresh copy
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CTTelephonyNetworkInfo *networkInfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
        [self performSelectorOnMainThread:@selector(updateCarrierInfoForCTCarrier:) withObject:networkInfo.subscriberCellularProvider waitUntilDone:NO];
    });
}

- (void)updateCarrierInfoForCTCarrier:(CTCarrier *)ctCarrier
{
    // use setValue instead of setObject here because ctCarrier could be nil, and any of its properties could be nil
    [self.carrierInfo setValue:ctCarrier.carrierName forKey:@"carrierName"];
    [self.carrierInfo setValue:ctCarrier.isoCountryCode forKey:@"isoCountryCode"];
    [self.carrierInfo setValue:ctCarrier.mobileCountryCode forKey:@"mobileCountryCode"];
    [self.carrierInfo setValue:ctCarrier.mobileNetworkCode forKey:@"mobileNetworkCode"];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.carrierInfo forKey:MOPUB_CARRIER_INFO_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Fetching Ads
- (NSMutableURLRequest *)buildConfiguredURLRequestWithURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPShouldHandleCookies:YES];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    return request;
}

- (NSString *)userAgent
{
    if (!_userAgent) {
        self.userAgent = [[[[UIWebView alloc] init] autorelease] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }
    
    return _userAgent;
}

- (MPAdServerCommunicatorMF *)buildMPAdServerCommunicatorWithDelegate:(id<MPAdServerCommunicatorDelegateMF>)delegate
{
    return [[(MPAdServerCommunicatorMF *)[MPAdServerCommunicatorMF alloc] initWithDelegate:delegate] autorelease];
}


#pragma mark - URL Handling

- (MPURLResolverMF *)buildMPURLResolver
{
    return [MPURLResolverMF resolver];
}

- (MPAdDestinationDisplayAgentMF *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegateMF>)delegate
{
    return [MPAdDestinationDisplayAgentMF agentWithDelegate:delegate];
}

#pragma mark - Utilities

- (id<MPAdAlertManagerProtocolMF>)buildMPAdAlertManagerWithDelegate:(id)delegate
{
    id<MPAdAlertManagerProtocolMF> adAlertManager = nil;
    
    Class adAlertManagerClass = NSClassFromString(@"MPAdAlertManager");
    if(adAlertManagerClass != nil)
    {
        adAlertManager = [[[adAlertManagerClass alloc] init] autorelease];
        [adAlertManager performSelector:@selector(setDelegate:) withObject:delegate];
    }
    
    return adAlertManager;
}

- (MPAdAlertGestureRecognizerMF *)buildMPAdAlertGestureRecognizerWithTarget:(id)target action:(SEL)action
{
    MPAdAlertGestureRecognizerMF *gestureRecognizer = nil;
    
    Class gestureRecognizerClass = NSClassFromString(@"MPAdAlertGestureRecognizer");
    if(gestureRecognizerClass != nil)
    {
        gestureRecognizer = [[[gestureRecognizerClass alloc] initWithTarget:target action:action] autorelease];
    }
    
    return gestureRecognizer;
}

- (NSOperationQueue *)sharedOperationQueue
{
    static NSOperationQueue *sharedOperationQueue = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedOperationQueue = [[NSOperationQueue alloc] init];
    });
    
    return sharedOperationQueue;
}

- (MPAnalyticsTrackerMF *)sharedMPAnalyticsTracker
{
    return [self singletonForClass:[MPAnalyticsTrackerMF class] provider:^id{
        return [MPAnalyticsTrackerMF tracker];
    }];
}

- (MPReachabilityMF *)sharedMPReachability
{
    return [self singletonForClass:[MPReachabilityMF class] provider:^id{
        return [MPReachabilityMF reachabilityForLocalWiFi];
    }];
}

- (NSDictionary *)sharedCarrierInfo
{
    return self.carrierInfo;
}

- (MPTimerMF *)buildMPTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats
{
    return [MPTimerMF timerWithTimeInterval:seconds target:target selector:selector repeats:repeats];
}

#pragma mark - Twitter Availability

- (void)resetTwitterAppInstallCheck
{
    self.twitterDeepLinkStatus = MPTwitterDeepLinkNotChecked;
}

- (BOOL)isTwitterInstalled
{
    
    if (self.twitterDeepLinkStatus == MPTwitterDeepLinkNotChecked)
    {
        BOOL twitterDeepLinkEnabled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://timeline"]];
        if (twitterDeepLinkEnabled)
        {
            self.twitterDeepLinkStatus = MPTwitterDeepLinkEnabled;
        }
        else
        {
            self.twitterDeepLinkStatus = MPTwitterDeepLinkDisabled;
        }
    }
    
    return (self.twitterDeepLinkStatus == MPTwitterDeepLinkEnabled);
}

+ (BOOL)deviceHasTwitterIntegration
{
    return !![MPCoreInstanceProviderMF tweetComposeVCClass];
}

+ (Class)tweetComposeVCClass
{
    return NSClassFromString(@"TWTweetComposeViewController");
}

- (BOOL)isNativeTwitterAccountPresent
{
    BOOL nativeTwitterAccountPresent = NO;
    if ([MPCoreInstanceProviderMF deviceHasTwitterIntegration])
    {
        nativeTwitterAccountPresent = (BOOL)[[MPCoreInstanceProviderMF tweetComposeVCClass] performSelector:@selector(canSendTweet)];
    }
    
    return nativeTwitterAccountPresent;
}

- (MPTwitterAvailability)twitterAvailabilityOnDevice
{
    MPTwitterAvailability twitterAvailability = MPTwitterAvailabilityNone;
    
    if ([self isTwitterInstalled])
    {
        twitterAvailability |= MPTwitterAvailabilityApp;
    }
    
    if ([self isNativeTwitterAccountPresent])
    {
        twitterAvailability |= MPTwitterAvailabilityNative;
    }
    
    return twitterAvailability;
}



@end
