//
//  KIFTestStep+ViewController.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep.h"

@interface KIFTestStep (ViewController)

+ (id)stepToVerifyPresentationOfViewControllerClass:(Class)klass;
+ (id)stepToVerifyAbsenceOfViewControllerClass:(Class)klass;
@end
