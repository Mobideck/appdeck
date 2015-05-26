//
//  MPAdConfiguration.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPAdConfigurationMF.h"

#import "MPConstantsMF.h"
#import "MpLoggingMF.h"
#import "math.h"
#import "NSJSONSerialization+MPAdditionsMF.h"

NSString * const kAdTypeHeaderKeyMF = @"X-Adtype";
NSString * const kClickthroughHeaderKeyMF = @"X-Clickthrough";
NSString * const kCustomSelectorHeaderKeyMF = @"X-Customselector";
NSString * const kCustomEventClassNameHeaderKeyMF = @"X-Custom-Event-Class-Name";
NSString * const kCustomEventClassDataHeaderKeyMF = @"X-Custom-Event-Class-Data";
NSString * const kFailUrlHeaderKeyMF = @"X-Failurl";
NSString * const kHeightHeaderKeyMF = @"X-Height";
NSString * const kImpressionTrackerHeaderKeyMF = @"X-Imptracker";
NSString * const kInterceptLinksHeaderKeyMF = @"X-Interceptlinks";
NSString * const kLaunchpageHeaderKeyMFMF = @"X-Launchpage";
NSString * const kNativeSDKParametersHeaderKeyMF = @"X-Nativeparams";
NSString * const kNetworkTypeHeaderKey = @"X-Networktype";
NSString * const kRefreshTimeHeaderKeyMF = @"X-Refreshtime";
NSString * const kAdTimeoutHeaderKeyMF = @"X-AdTimeout";
NSString * const kScrollableHeaderKeyMF = @"X-Scrollable";
NSString * const kWidthHeaderKeyMF = @"X-Width";
NSString * const kDspCreativeIdKeyMF = @"X-DspCreativeid";
NSString * const kPrecacheRequiredKeyMF = @"X-PrecacheRequired";

NSString * const kInterstitialAdTypeHeaderKeyMF = @"X-Fulladtype";
NSString * const kOrientationTypeHeaderKeyMF = @"X-Orientation";

NSString * const kAdTypeHtml = @"html";
NSString * const kAdTypeInterstitial = @"interstitial";
NSString * const kAdTypeMraid = @"mraid";
NSString * const kAdTypeClearMF = @"clear";
NSString * const kAdTypeNativeMF = @"json";

@interface MPAdConfigurationMF ()

@property (nonatomic, copy) NSString *adResponseHTMLString;

- (MPAdType)adTypeFromHeaders:(NSDictionary *)headers;
- (NSString *)networkTypeFromHeaders:(NSDictionary *)headers;
- (NSTimeInterval)refreshIntervalFromHeaders:(NSDictionary *)headers;
- (NSDictionary *)dictionaryFromHeaders:(NSDictionary *)headers forKey:(NSString *)key;
- (NSURL *)URLFromHeaders:(NSDictionary *)headers forKey:(NSString *)key;
- (Class)setUpCustomEventClassFromHeaders:(NSDictionary *)headers;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPAdConfigurationMF

@synthesize adType = _adType;
@synthesize networkType = _networkType;
@synthesize preferredSize = _preferredSize;
@synthesize clickTrackingURL = _clickTrackingURL;
@synthesize impressionTrackingURL = _impressionTrackingURL;
@synthesize failoverURL = _failoverURL;
@synthesize interceptURLPrefix = _interceptURLPrefix;
@synthesize shouldInterceptLinks = _shouldInterceptLinks;
@synthesize scrollable = _scrollable;
@synthesize refreshInterval = _refreshInterval;
@synthesize adTimeoutInterval = _adTimeoutInterval;
@synthesize adResponseData = _adResponseData;
@synthesize adResponseHTMLString = _adResponseHTMLString;
@synthesize nativeSDKParameters = _nativeSDKParameters;
@synthesize orientationType = _orientationType;
@synthesize customEventClass = _customEventClass;
@synthesize customEventClassData = _customEventClassData;
@synthesize customSelectorName = _customSelectorName;
@synthesize dspCreativeId = _dspCreativeId;
@synthesize precacheRequired = _precacheRequired;
@synthesize creationTimestamp = _creationTimestamp;

- (id)initWithHeaders:(NSDictionary *)headers data:(NSData *)data
{
    self = [super init];
    if (self) {
        self.adResponseData = data;

        self.adType = [self adTypeFromHeaders:headers];

        self.networkType = [self networkTypeFromHeaders:headers];
        self.networkType = self.networkType ? self.networkType : @"";

        self.preferredSize = CGSizeMake([[headers objectForKey:kWidthHeaderKeyMF] floatValue],
                                        [[headers objectForKey:kHeightHeaderKeyMF] floatValue]);

        self.clickTrackingURL = [self URLFromHeaders:headers
                                              forKey:kClickthroughHeaderKeyMF];
        self.impressionTrackingURL = [self URLFromHeaders:headers
                                                   forKey:kImpressionTrackerHeaderKeyMF];
        self.failoverURL = [self URLFromHeaders:headers
                                         forKey:kFailUrlHeaderKeyMF];
        self.interceptURLPrefix = [self URLFromHeaders:headers
                                                forKey:kLaunchpageHeaderKeyMFMF];

        NSNumber *shouldInterceptLinks = [headers objectForKey:kInterceptLinksHeaderKeyMF];
        self.shouldInterceptLinks = shouldInterceptLinks ? [shouldInterceptLinks boolValue] : YES;
        self.scrollable = [[headers objectForKey:kScrollableHeaderKeyMF] boolValue];
        self.refreshInterval = [self refreshIntervalFromHeaders:headers];
        self.adTimeoutInterval = [self adTimeoutIntervalFromHeaders:headers];


        self.nativeSDKParameters = [self dictionaryFromHeaders:headers
                                                        forKey:kNativeSDKParametersHeaderKeyMF];
        self.customSelectorName = [headers objectForKey:kCustomSelectorHeaderKeyMF];

        self.orientationType = [self orientationTypeFromHeaders:headers];

        self.customEventClass = [self setUpCustomEventClassFromHeaders:headers];

        self.customEventClassData = [self customEventClassDataFromHeaders:headers];

        self.dspCreativeId = [headers objectForKey:kDspCreativeIdKeyMF];

        self.precacheRequired = [[headers objectForKey:kPrecacheRequiredKeyMF] boolValue];

        self.creationTimestamp = [NSDate date];
    }
    return self;
}

- (Class)setUpCustomEventClassFromHeaders:(NSDictionary *)headers
{
    NSString *customEventClassName = [headers objectForKey:kCustomEventClassNameHeaderKeyMF];

    NSMutableDictionary *convertedCustomEvents = [NSMutableDictionary dictionary];
    if (self.adType == MPAdTypeBanner) {
        [convertedCustomEvents setObject:@"MPiAdBannerCustomEvent" forKey:@"iAd"];
        [convertedCustomEvents setObject:@"MPGoogleAdMobBannerCustomEvent" forKey:@"admob_native"];
        [convertedCustomEvents setObject:@"MPMillennialBannerCustomEvent" forKey:@"millennial_native"];
        [convertedCustomEvents setObject:@"MPHTMLBannerCustomEvent" forKey:@"html"];
        [convertedCustomEvents setObject:@"MPMRAIDBannerCustomEvent" forKey:@"mraid"];
    } else if (self.adType == MPAdTypeInterstitial) {
        [convertedCustomEvents setObject:@"MPiAdInterstitialCustomEvent" forKey:@"iAd_full"];
        [convertedCustomEvents setObject:@"MPGoogleAdMobInterstitialCustomEvent" forKey:@"admob_full"];
        [convertedCustomEvents setObject:@"MPMillennialInterstitialCustomEvent" forKey:@"millennial_full"];
        [convertedCustomEvents setObject:@"MPHTMLInterstitialCustomEvent" forKey:@"html"];
        [convertedCustomEvents setObject:@"MPMRAIDInterstitialCustomEvent" forKey:@"mraid"];
    }
    if ([convertedCustomEvents objectForKey:self.networkType]) {
        customEventClassName = [convertedCustomEvents objectForKey:self.networkType];
    }

    Class customEventClass = NSClassFromString(customEventClassName);

    if (customEventClassName && !customEventClass) {
        MPLogWarnMF(@"Could not find custom event class named %@", customEventClassName);
    }

    return customEventClass;
}



- (NSDictionary *)customEventClassDataFromHeaders:(NSDictionary *)headers
{
    NSDictionary *result = [self dictionaryFromHeaders:headers forKey:kCustomEventClassDataHeaderKeyMF];
    if (!result) {
        result = [self dictionaryFromHeaders:headers forKey:kNativeSDKParametersHeaderKeyMF];
    }
    return result;
}

- (void)dealloc
{
    self.networkType = nil;
    self.clickTrackingURL = nil;
    self.impressionTrackingURL = nil;
    self.failoverURL = nil;
    self.interceptURLPrefix = nil;
    self.adResponseData = nil;
    self.adResponseHTMLString = nil;
    self.nativeSDKParameters = nil;
    self.customSelectorName = nil;
    self.customEventClassData = nil;
    self.dspCreativeId = nil;
    self.creationTimestamp = nil;

    [super dealloc];
}

- (BOOL)hasPreferredSize
{
    return (self.preferredSize.width > 0 && self.preferredSize.height > 0);
}

- (NSString *)adResponseHTMLString
{
    if (!_adResponseHTMLString) {
        self.adResponseHTMLString = [[[NSString alloc] initWithData:self.adResponseData
                                                           encoding:NSUTF8StringEncoding] autorelease];
    }

    return _adResponseHTMLString;
}

- (NSString *)clickDetectionURLPrefix
{
    return self.interceptURLPrefix.absoluteString ? self.interceptURLPrefix.absoluteString : @"";
}

#pragma mark - Private

- (MPAdType)adTypeFromHeaders:(NSDictionary *)headers
{
    NSString *adTypeString = [headers objectForKey:kAdTypeHeaderKeyMF];

    if ([adTypeString isEqualToString:@"interstitial"]) {
        return MPAdTypeInterstitial;
    } else if (adTypeString &&
               [headers objectForKey:kOrientationTypeHeaderKeyMF]) {
        return MPAdTypeInterstitial;
    } else if (adTypeString) {
        return MPAdTypeBanner;
    } else {
        return MPAdTypeUnknown;
    }
}

- (NSString *)networkTypeFromHeaders:(NSDictionary *)headers
{
    NSString *adTypeString = [headers objectForKey:kAdTypeHeaderKeyMF];
    if ([adTypeString isEqualToString:@"interstitial"]) {
        return [headers objectForKey:kInterstitialAdTypeHeaderKeyMF];
    } else {
        return adTypeString;
    }
}

- (NSURL *)URLFromHeaders:(NSDictionary *)headers forKey:(NSString *)key
{
    NSString *URLString = [headers objectForKey:key];
    return URLString ? [NSURL URLWithString:URLString] : nil;
}

- (NSDictionary *)dictionaryFromHeaders:(NSDictionary *)headers forKey:(NSString *)key
{
    NSData *data = [(NSString *)[headers objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSONFromHeaders = nil;
    if (data) {
        JSONFromHeaders = [NSJSONSerialization mp_JSONObjectWithData:data options:NSJSONReadingMutableContainers clearNullObjects:YES error:nil];
    }
    return JSONFromHeaders;
}

- (NSTimeInterval)refreshIntervalFromHeaders:(NSDictionary *)headers
{
    NSString *intervalString = [headers objectForKey:kRefreshTimeHeaderKeyMF];
    NSTimeInterval interval = -1;
    if (intervalString) {
        interval = [intervalString doubleValue];
        if (interval < MINIMUM_REFRESH_INTERVAL) {
            interval = MINIMUM_REFRESH_INTERVAL;
        }
    }
    return interval;
}

- (NSTimeInterval)adTimeoutIntervalFromHeaders:(NSDictionary *)headers
{
    NSString *intervalString = [headers objectForKey:kAdTimeoutHeaderKeyMF];
    NSTimeInterval interval = -1;
    if (intervalString) {
        int parsedInt = -1;
        BOOL isNumber = [[NSScanner scannerWithString:intervalString] scanInt:&parsedInt];
        if (isNumber && parsedInt >= 0) {
            interval = parsedInt;
        }
    }

    return interval;
}

- (MPInterstitialOrientationType)orientationTypeFromHeaders:(NSDictionary *)headers
{
    NSString *orientation = [headers objectForKey:kOrientationTypeHeaderKeyMF];
    if ([orientation isEqualToString:@"p"]) {
        return MPInterstitialOrientationTypePortrait;
    } else if ([orientation isEqualToString:@"l"]) {
        return MPInterstitialOrientationTypeLandscape;
    } else {
        return MPInterstitialOrientationTypeAll;
    }
}

@end
