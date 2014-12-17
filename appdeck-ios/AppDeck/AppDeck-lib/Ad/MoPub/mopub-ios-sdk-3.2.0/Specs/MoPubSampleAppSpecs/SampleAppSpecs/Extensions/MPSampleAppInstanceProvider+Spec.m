//
//  MPSampleAppInstanceProvider+Spec.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

@implementation MPSampleAppInstanceProvider (Spec)

+ (MPSampleAppInstanceProvider *)sharedProvider
{
    return fakeProvider;
}

@end
