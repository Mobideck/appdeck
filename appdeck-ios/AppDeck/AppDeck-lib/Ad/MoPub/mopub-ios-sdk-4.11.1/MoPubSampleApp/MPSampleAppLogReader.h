//
//  MPSampleAppLogReader.h
//  MoPubSampleApp
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPSampleAppLogReader : NSObject

+ (MPSampleAppLogReader *)sharedLogReader;

- (void)beginReadingLogMessages;

@end
