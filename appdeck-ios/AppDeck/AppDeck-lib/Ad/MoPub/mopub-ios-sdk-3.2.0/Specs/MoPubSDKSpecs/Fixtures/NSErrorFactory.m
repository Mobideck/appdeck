//
//  NSErrorFactory.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "NSErrorFactory.h"

@implementation NSErrorFactory

+ (NSError *)genericError
{
    NSString *domain = [NSString stringWithFormat:@"com.mopub.%f", [NSDate timeIntervalSinceReferenceDate]];
    return [NSError errorWithDomain:domain code:-100 userInfo:nil];
}

@end
