//
//  UITableViewCell+MPNativeAd.m
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UITableViewCell+MPNativeAdMF.h"
#import <objc/runtime.h>

static char MPNativeAdKey;

@implementation UITableViewCell (MPNativeAdMF)

- (void)mp_removeNativeAd
{
    [self mp_setNativeAd:nil];
}

- (void)mp_setNativeAd:(MPNativeAdMF *)adObject
{
    objc_setAssociatedObject(self, &MPNativeAdKey, adObject, OBJC_ASSOCIATION_ASSIGN);
}

- (MPNativeAdMF *)mp_nativeAd
{
    return (MPNativeAdMF *)objc_getAssociatedObject(self, &MPNativeAdKey);
}

@end
