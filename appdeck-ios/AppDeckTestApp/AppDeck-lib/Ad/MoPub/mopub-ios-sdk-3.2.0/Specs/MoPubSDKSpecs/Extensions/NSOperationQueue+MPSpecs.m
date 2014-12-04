//
//  NSOperationQueue+MPSpecs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "NSOperationQueue+MPSpecs.h"
#import <objc/runtime.h>

static BOOL gCancelledAllOperationsCalled;
static NSUInteger gAddOperationsCount;

@implementation NSOperationQueue (MPSpecs)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        Method originalMethod = class_getInstanceMethod(class, @selector(cancelAllOperations));
        Method swizzledMethod = class_getInstanceMethod(class, @selector(mp_cancelAllOperations));

        method_exchangeImplementations(originalMethod, swizzledMethod);

        originalMethod = class_getInstanceMethod(class, @selector(addOperationWithBlock:));
        swizzledMethod = class_getInstanceMethod(class, @selector(mp_addOperationWithBlock:));

        method_exchangeImplementations(originalMethod, swizzledMethod);
    });

}

+ (void)mp_resetCancelAllOperationsCalled
{
    gCancelledAllOperationsCalled = NO;
}

+ (BOOL)mp_cancelAllOperationsCalled
{
    return gCancelledAllOperationsCalled;
}

+ (void)mp_resetAddOperationWithBlockCount
{
    gAddOperationsCount = 0;
}

+ (NSUInteger)mp_addOperationWithBlockCount
{
    return gAddOperationsCount;
}

#pragma mark - Swizzled

- (void)mp_cancelAllOperations
{
    gCancelledAllOperationsCalled = YES;
    [self mp_cancelAllOperations];
}

- (void)mp_addOperationWithBlock:(void (^)(void))block
{
    ++gAddOperationsCount;
    [self mp_addOperationWithBlock:block];
}

@end
