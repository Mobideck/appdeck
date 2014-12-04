//
//  KIFHelper.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFHelper.h"
#import "UIApplication-KIFAdditions.h"
#import "UIView-KIFAdditions.h"

@interface UIViewController (secret)

- (BOOL)isInAnimatedVCTransition;

@end

@implementation KIFHelper

+ (UIViewController *)topMostViewController
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    return [self getLeafController:window.rootViewController];
}

+ (UIViewController *)getLeafController:(UIViewController *)controller
{
    if (controller.presentedViewController) {
        return [self getLeafController:controller.presentedViewController];
    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self getLeafController:[(UINavigationController *)controller topViewController]];
    }
    return controller;
}

+ (NSArray *)findViewsOfClass:(Class)klass
{
    return [[self topMostViewController].view subviewsWithClassNamePrefix:NSStringFromClass(klass)];
}

+ (NSArray *)findViewsWithClassNamePrefix:(NSString *)prefix
{
    return [[self topMostViewController].view subviewsWithClassNamePrefix:prefix];
}


+ (void)waitForViewControllerToStopAnimating:(UIViewController *)controller
{
    while ([controller isInAnimatedVCTransition]) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1f, false);
    }
}

@end
