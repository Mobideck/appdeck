//
//  UIApplication+MPSpecs.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UIApplication+MPSpecs.h"
#import "objc/runtime.h"
#import "NSURL+MPAdditions.h"

static char CAN_OPEN_TELEPHONE_SCHEMES_KEY;
static char LAST_OPENED_URL_KEY;
static char STATUS_BAR_ORIENTATION;
static char SUPPORTED_INTERFACE_ORIENTATIONS;

static BOOL gTwitterInstalled;

@implementation UIApplication (MPSpecs)

+ (void)beforeEach
{
    [[UIApplication sharedApplication] setLastOpenedURL:nil];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
}

- (NSURL *)lastOpenedURL
{
    return objc_getAssociatedObject(self, &LAST_OPENED_URL_KEY);
}

- (void)setLastOpenedURL:(NSURL *)url
{
    objc_setAssociatedObject(self, &LAST_OPENED_URL_KEY, url, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)openURL:(NSURL *)url
{
    self.lastOpenedURL = url;
    return [self canOpenURL:url];
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)orientation
{
    objc_setAssociatedObject(self, &STATUS_BAR_ORIENTATION, [NSNumber numberWithInteger:orientation], OBJC_ASSOCIATION_RETAIN);
}

- (UIInterfaceOrientation)statusBarOrientation
{
    return [objc_getAssociatedObject(self, &STATUS_BAR_ORIENTATION) integerValue];
}

- (void)setSupportedInterfaceOrientations:(UIInterfaceOrientationMask)orientationMask
{
    objc_setAssociatedObject(self, &SUPPORTED_INTERFACE_ORIENTATIONS, [NSNumber numberWithUnsignedInteger:orientationMask], OBJC_ASSOCIATION_RETAIN);
}

- (NSUInteger)supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return [objc_getAssociatedObject(self, &SUPPORTED_INTERFACE_ORIENTATIONS) unsignedIntegerValue];
}

#pragma mark - Swizzling

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        //swizzling canOpenURL:
        SEL originalCanOpenURLSelector = @selector(canOpenURL:);
        SEL swizzledCanOpenURLSelector = @selector(test_CanOpenURL:);

        Method originalCanOpenURLMethod = class_getInstanceMethod(class, originalCanOpenURLSelector);
        Method swizzledCanOpenURLMethod = class_getInstanceMethod(class, swizzledCanOpenURLSelector);

        BOOL didAddCanOpenURLMethod =
        class_addMethod(class, originalCanOpenURLSelector, method_getImplementation(swizzledCanOpenURLMethod), method_getTypeEncoding(swizzledCanOpenURLMethod));

        if (didAddCanOpenURLMethod) {
            class_replaceMethod(class, swizzledCanOpenURLSelector, method_getImplementation(originalCanOpenURLMethod), method_getTypeEncoding(originalCanOpenURLMethod));
        } else {
            method_exchangeImplementations(originalCanOpenURLMethod, swizzledCanOpenURLMethod);
        }
    });
}

- (void)mp_setCanOpenTelephoneSchemes:(BOOL)canOpen
{
    objc_setAssociatedObject(self, &CAN_OPEN_TELEPHONE_SCHEMES_KEY, @(canOpen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Test Twitter App Installation

- (void)setTwitterInstalled:(BOOL)installed
{
    gTwitterInstalled = installed;
}

- (BOOL)test_CanOpenURL:(NSURL *)url
{
    BOOL canOpenURL = NO;

    BOOL canOpenTelSchemes = [objc_getAssociatedObject(self, &CAN_OPEN_TELEPHONE_SCHEMES_KEY) boolValue];

    if (canOpenTelSchemes && ([url mp_hasTelephonePromptScheme] || [url mp_hasTelephoneScheme]))
    {
        return YES;
    }
    else if ([url.absoluteString isEqualToString:@"twitter://timeline"])
    {
        canOpenURL = gTwitterInstalled;
    }
    else
    {
        canOpenURL = [self test_CanOpenURL:url];
    }

    return canOpenURL;
}

@end
