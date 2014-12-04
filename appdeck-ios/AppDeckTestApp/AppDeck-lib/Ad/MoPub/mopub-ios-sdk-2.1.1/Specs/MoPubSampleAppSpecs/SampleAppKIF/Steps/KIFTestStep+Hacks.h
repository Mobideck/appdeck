//
//  KIFTestStep+Hacks.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep.h"

typedef void(^KIFTestStepBlock)(void);

@interface KIFTestStep (Hacks)

+ (KIFTestStep *)stepToPerformBlock:(KIFTestStepBlock)block;
+ (KIFTestStep *)stepToPrintOutViewHierarchy;

@end
