//
//  FakeMPReachability.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPReachability.h"

@interface FakeMPReachability : MPReachability

@property (nonatomic, assign) BOOL hasWifi;
@property (nonatomic, assign) BOOL hasCellular;

@end
