//
//  MPLogEventRecorderSpecHelper.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPLogEvent;

@interface MPLogEventRecorderSpecHelper : NSObject

+ (void)mp_specsAddEvent:(MPLogEvent *)event;

@end
