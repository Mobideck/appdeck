//
//  KIFHelper.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KIFHelper : NSObject

+ (UIViewController *)topMostViewController;
+ (UIViewController *)getLeafController:(UIViewController *)controller;

+ (NSArray *)findViewsOfClass:(Class)klass;
+ (NSArray *)findViewsWithClassNamePrefix:(NSString *)prefix;

+ (void)waitForViewControllerToStopAnimating:(UIViewController *)controller;

@end
