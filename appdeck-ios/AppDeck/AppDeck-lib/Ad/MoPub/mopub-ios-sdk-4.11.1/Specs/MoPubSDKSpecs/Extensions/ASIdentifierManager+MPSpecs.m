//
//  ASIdentifierManager+MPSpecs.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "ASIdentifierManager+MPSpecs.h"
#import <objc/runtime.h>

static NSString* const kMPSpecAllZeroedSampleAdvertisingIdentifier = @"00000000-0000-0000-0000-000000000000";


static MPSpecAdvertisingIdentifierType gAdvertisingIdentifierType;

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

+ (void)useAdvertisingIdentifierType:(MPSpecAdvertisingIdentifierType)type
{
    gAdvertisingIdentifierType = type;
}

- (NSUUID *)test_advertisingIdentifier
{
    if (gAdvertisingIdentifierType == MPSpecAdvertisingIdentifierTypeNil) {
        return nil;
    } else if (gAdvertisingIdentifierType == MPSpecAdvertisingIdentifierTypeAllZero) {
        return [[NSUUID alloc] initWithUUIDString:kMPSpecAllZeroedSampleAdvertisingIdentifier];
    }

    return [self test_advertisingIdentifier];
}

@end
