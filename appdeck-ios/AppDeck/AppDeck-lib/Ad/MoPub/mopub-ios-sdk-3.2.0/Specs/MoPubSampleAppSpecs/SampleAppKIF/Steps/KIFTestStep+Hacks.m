//
//  KIFTestStep+Hacks.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+Hacks.h"

@implementation KIFTestStep (Hacks)

+ (KIFTestStep *)stepToPerformBlock:(KIFTestStepBlock)block
{
    return [KIFTestStep stepWithDescription:@"Perform block" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        block();

        return KIFTestStepResultSuccess;
    }];
}

+ (KIFTestStep *)stepToPrintOutViewHierarchy
{
    return [KIFTestStep stepWithDescription:@"Print out view hierarchy" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        [self printSubviews:[[UIApplication sharedApplication] keyWindow] indentationString:@""];

        return KIFTestStepResultSuccess;
    }];
}

+ (void)printSubviews:(UIView *)view indentationString:(NSString *)indentationString
{
    NSMutableArray *strings = [NSMutableArray array];

    [strings addObject:[NSString stringWithFormat:@"\033[0;40;36m%@\033[0m", [view class]]];
    if (view.accessibilityLabel) {
        [strings addObject:[NSString stringWithFormat:@"\033[0;40;32m(Label:%@)\033[0m", view.accessibilityLabel]];
    }
    if (view.hidden) {
        [strings addObject:@"\033[0;40;31m**HIDDEN**\033[0m"];
    }
    NSLog(@"%@%@", indentationString, [strings componentsJoinedByString:@" "]);
    for (UIView *subview in view.subviews) {
        [self printSubviews:subview indentationString:[indentationString stringByAppendingString:@"  "]];
    }
}

@end
