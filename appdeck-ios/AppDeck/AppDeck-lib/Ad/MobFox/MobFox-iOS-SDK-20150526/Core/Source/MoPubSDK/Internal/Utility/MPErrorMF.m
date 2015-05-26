//
//  MPAdRequestError.m
//  MoPub
//
//  Copyright (c) 2012 MoPub. All rights reserved.
//

#import "MPErrorMF.h"

NSString * const kLaunchpageHeaderKeyMF = @"com.mopub.iossdk";

@implementation MPErrorMF

+ (MPErrorMF *)errorWithCode:(MPErrorCode)code
{
    return [self errorWithDomain:kLaunchpageHeaderKeyMF code:code userInfo:nil];
}

@end
