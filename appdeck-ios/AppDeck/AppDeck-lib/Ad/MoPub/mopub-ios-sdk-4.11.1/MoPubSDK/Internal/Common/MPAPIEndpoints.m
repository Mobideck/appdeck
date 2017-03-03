//
//  MPAPIEndpoints.m
//  MoPub
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPAPIEndpoints.h"
#import "MPConstants.h"

@implementation MPAPIEndpoints

static BOOL sUsesHTTPS = YES;

+ (void)setUsesHTTPS:(BOOL)usesHTTPS
{
    sUsesHTTPS = usesHTTPS;
}

+ (NSString *)baseURL
{
    return [@"http://" stringByAppendingString:MOPUB_BASE_HOSTNAME];
}

+ (NSString *)baseURLScheme
{
    return sUsesHTTPS ? @"https://" : @"http://";
}

+ (NSString *)baseURLStringWithPath:(NSString *)path testing:(BOOL)testing
{
    return [NSString stringWithFormat:@"%@%@%@",
            [[self class] baseURLScheme],
            testing ? MOPUB_BASE_HOSTNAME_FOR_TESTING : MOPUB_BASE_HOSTNAME,
            path];
}

@end
