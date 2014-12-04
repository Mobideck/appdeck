//
//  ASIdentifierManager+MPSpecs.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "ASIdentifierManager+MPSpecs.h"
#import <objc/runtime.h>

static BOOL gUseNilForAdvertisingIdentifier;

@implementation ASIdentifierManager (MPSpecs)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(advertisingIdentifier);
        SEL swizzledSelector = @selector(test_advertisingIdentifier);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

+ (void)useNilForAdvertisingIdentifier:(BOOL)useNil
{
    gUseNilForAdvertisingIdentifier = useNil;
}

- (NSUUID *)test_advertisingIdentifier
{
    if (gUseNilForAdvertisingIdentifier) {
        return nil;
    }

    return [self test_advertisingIdentifier];
}

@end
