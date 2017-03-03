//
//  MPLogEventRecorderSpecHelper.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPLogEventRecorderSpecHelper.h"
#import "MPLogEvent.h"
#import "MPLogEventRecorder.h"

@implementation MPLogEventRecorderSpecHelper

+ (void)mp_specsAddEvent:(MPLogEvent *)event
{
    MPAddLogEvent(event);
}

@end
