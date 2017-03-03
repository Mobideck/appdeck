//
//  FakeMPLogEventRecorder.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPLogEventRecorder.h"

@interface FakeMPLogEventRecorder : MPLogEventRecorder

@property (nonatomic) NSMutableArray *events;

@end
