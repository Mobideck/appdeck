//
//  UIApplication+setStatusBarHidden.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 25/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "UIApplication+setStatusBarHidden.h"
#import "AppDeck.h"
#import "LoaderViewController.h"
#import "SwipeViewController.h"
#import "LoaderChildViewController.h"

@implementation UIApplication (setStatusBarHidden)
/*
typedef struct objc_method *Method;
Method class_getClassMethod(Class aClass, SEL aSelector);
void method_exchangeImplementations(Method m1, Method m2);

+ (void)load {
        method_exchangeImplementations(class_getClassMethod(self, @selector(setStatusBarHidden:animated:)),
                                       class_getClassMethod(self, @selector(altSetStatusBarHidden:animated:)));
}*/

-(void)altSetStatusBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    //NSLog(@"try to hide all");
    /*
    AppDeck *appDeck = [AppDeck sharedInstance];
    
    if (appDeck.iosVersion >= 7.0)
    {
        LoaderChildViewController *child = [appDeck.loader getCurrentChild];
        child.isFullScreen = hidden;
    } else {
        
    }*/
}

-(void)altSetStatusBarHidden:(BOOL)hidden
{
    //NSLog(@"try to hide all");
/*    AppDeck *appDeck = [AppDeck sharedInstance];
    
    if (appDeck.iosVersion >= 7.0)
    {
        LoaderChildViewController *child = [appDeck.loader getCurrentChild];
        child.isFullScreen = hidden;
    } else {
        
    }
 */
}

-(void)altSetStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation
{
    //NSLog(@"try to hide all");
    /*
    AppDeck *appDeck = [AppDeck sharedInstance];
    
    if (appDeck.iosVersion >= 7.0)
    {
        LoaderChildViewController *child = [appDeck.loader getCurrentChild];
        child.isFullScreen = hidden;
    } else {
        
    }
    */
}

@end
