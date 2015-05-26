//
//  MPAdConfiguration.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPGlobalMF.h"

enum {
    MPAdTypeUnknown = -1,
    MPAdTypeBanner = 0,
    MPAdTypeInterstitial = 1
};
typedef NSUInteger MPAdType;

extern NSString * const kAdTypeHeaderKeyMF;
extern NSString * const kClickthroughHeaderKeyMF;
extern NSString * const kCustomSelectorHeaderKeyMF;
extern NSString * const kCustomEventClassNameHeaderKeyMF;
extern NSString * const kCustomEventClassDataHeaderKeyMF;
extern NSString * const kFailUrlHeaderKeyMF;
extern NSString * const kHeightHeaderKeyMF;
extern NSString * const kImpressionTrackerHeaderKeyMF;
extern NSString * const kInterceptLinksHeaderKeyMF;
extern NSString * const kLaunchpageHeaderKeyMFMF;
extern NSString * const kNativeSDKParametersHeaderKeyMF;
extern NSString * const kNetworkTypeHeaderKey;
extern NSString * const kRefreshTimeHeaderKeyMF;
extern NSString * const kAdTimeoutHeaderKeyMF;
extern NSString * const kScrollableHeaderKeyMF;
extern NSString * const kWidthHeaderKeyMF;
extern NSString * const kDspCreativeIdKeyMF;
extern NSString * const kPrecacheRequiredKeyMF;

extern NSString * const kInterstitialAdTypeHeaderKeyMF;
extern NSString * const kOrientationTypeHeaderKeyMF;

extern NSString * const kAdTypeHtml;
extern NSString * const kAdTypeInterstitial;
extern NSString * const kAdTypeMraid;
extern NSString * const kAdTypeClearMF;
extern NSString * const kAdTypeNativeMF;

@interface MPAdConfigurationMF : NSObject

@property (nonatomic, assign) MPAdType adType;
@property (nonatomic, copy) NSString *networkType;
@property (nonatomic, assign) CGSize preferredSize;
@property (nonatomic, retain) NSURL *clickTrackingURL;
@property (nonatomic, retain) NSURL *impressionTrackingURL;
@property (nonatomic, retain) NSURL *failoverURL;
@property (nonatomic, retain) NSURL *interceptURLPrefix;
@property (nonatomic, assign) BOOL shouldInterceptLinks;
@property (nonatomic, assign) BOOL scrollable;
@property (nonatomic, assign) NSTimeInterval refreshInterval;
@property (nonatomic, assign) NSTimeInterval adTimeoutInterval;
@property (nonatomic, copy) NSData *adResponseData;
@property (nonatomic, retain) NSDictionary *nativeSDKParameters;
@property (nonatomic, copy) NSString *customSelectorName;
@property (nonatomic, assign) Class customEventClass;
@property (nonatomic, retain) NSDictionary *customEventClassData;
@property (nonatomic, assign) MPInterstitialOrientationType orientationType;
@property (nonatomic, copy) NSString *dspCreativeId;
@property (nonatomic, assign) BOOL precacheRequired;
@property (nonatomic, retain) NSDate *creationTimestamp;

- (id)initWithHeaders:(NSDictionary *)headers data:(NSData *)data;

- (BOOL)hasPreferredSize;
- (NSString *)adResponseHTMLString;
- (NSString *)clickDetectionURLPrefix;

@end
