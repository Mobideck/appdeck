//
//  UIApplication+KIF.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (KIF)

- (NSURL *)lastOpenedURL;
- (void)resetLastOpenedURL;

@end
