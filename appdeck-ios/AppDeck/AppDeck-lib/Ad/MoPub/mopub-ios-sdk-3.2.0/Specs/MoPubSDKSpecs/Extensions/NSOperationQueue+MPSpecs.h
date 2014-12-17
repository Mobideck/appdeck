//
//  NSOperationQueue+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (MPSpecs)

// Tracking whether or not cancel operations was called.
+ (void)mp_resetCancelAllOperationsCalled;
+ (BOOL)mp_cancelAllOperationsCalled;

// Tracking addOperationWithBlock.
+ (void)mp_resetAddOperationWithBlockCount;
+ (NSUInteger)mp_addOperationWithBlockCount;

@end
