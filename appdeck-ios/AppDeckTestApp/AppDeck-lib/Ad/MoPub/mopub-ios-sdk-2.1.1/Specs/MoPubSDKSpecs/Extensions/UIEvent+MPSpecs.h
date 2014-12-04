//
//  UIEvent+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITouch+MPSpecs.h"

@interface UIEvent (MPSpecs)

- (id)initWithTouch:(UITouch *)touch;

@end
