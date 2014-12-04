//
//  KIFTestStep+ActivityIndicator.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep.h"

@interface KIFTestStep (ActivityIndicator)

+ (id)stepToWaitUntilActivityIndicatorIsNotAnimating;
+ (id)stepToWaitUntilNetworkActivityIndicatorIsNotAnimating;

@end
