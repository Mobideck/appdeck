//
//  TWTweetComposeViewController+MPSpecs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "TWTweetComposeViewController+MPSpecs.h"
#import "objc/runtime.h"

static BOOL gTwitterNativeAvailable;


@implementation TWTweetComposeViewController (MPSpecs)

+ (void)setNativeTwitterAvailable:(BOOL)available
{
    gTwitterNativeAvailable = available;

}

+ (BOOL)canSendTweet
{
    return gTwitterNativeAvailable;
}

@end