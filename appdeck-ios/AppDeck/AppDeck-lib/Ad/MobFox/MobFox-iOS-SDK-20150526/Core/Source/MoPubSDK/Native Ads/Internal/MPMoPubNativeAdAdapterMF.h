//
//  MPMoPubNativeAdAdapter.h
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeAdAdapterMF.h"

@interface MPMoPubNativeAdAdapterMF : NSObject <MPNativeAdAdapterMF>

@property (nonatomic, retain) NSArray *impressionTrackers;
@property (nonatomic, retain) NSURL *engagementTrackingURL;

- (instancetype)initWithAdProperties:(NSMutableDictionary *)properties;

@end
