//
//  FBAdView+Specs.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface FBAdView (Specs)

- (FBAdSize)fbAdSize;
+ (BOOL)autoRefreshWasDisabled;
+ (void)resetAutoRefreshWasDisabledValue;

@end
