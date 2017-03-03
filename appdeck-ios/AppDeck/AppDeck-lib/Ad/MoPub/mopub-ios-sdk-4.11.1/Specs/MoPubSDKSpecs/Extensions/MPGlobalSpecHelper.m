//
//  MPGlobalSpecHelper.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPGlobalSpecHelper.h"

@implementation MPGlobalSpecHelper

+ (CGSize)screenResolution
{
    return MPScreenResolution();
}

+ (CGRect)screenBounds
{
    return MPScreenBounds();
}

+ (CGFloat)deviceScaleFactor
{
    return MPDeviceScaleFactor();
}

+ (NSDictionary *)dictionaryFromQueryString:(NSString *)query
{
    return MPDictionaryFromQueryString(query);
}

+ (NSArray *)convertStrArrayToURLArray:(NSArray *)strArray
{
    return MPConvertStringArrayToURLArray(strArray);
}

@end
