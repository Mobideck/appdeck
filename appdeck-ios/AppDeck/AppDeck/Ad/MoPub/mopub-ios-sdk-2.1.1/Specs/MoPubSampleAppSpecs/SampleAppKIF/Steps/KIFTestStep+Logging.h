//
//  KIFTestStep+Logging.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep.h"

@interface KIFTestStep (Logging)

+ (id)stepToLogImpressionForAdUnit:(NSString *)adUnitId;
+ (id)stepToLogClickForAdUnit:(NSString *)adUnitId;

@end
