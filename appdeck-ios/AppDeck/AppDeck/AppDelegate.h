//
//  AppDelegate.h
//  AppDeck
//
//  Copyright (c) 2013 Mobideck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../AppDeck-lib/AppDeck.h"
#import "../AppDeck-lib/LoaderViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

}

+ (AppDelegate *)sharedAppDelegate;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LoaderViewController *appDeck;

@end
