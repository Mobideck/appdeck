//
//  MyTabBarViewController.h
//  AppDeck
//
//  Created by hanine ben saad on 16/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoaderViewController.h"
#import "LoaderChildViewController.h"
#import "LoaderChildViewController.h"


@interface MyTabBarViewController : UIViewController

@property (nonatomic, retain) NSArray*controllersArray;
@property (nonatomic, retain) UITabBarController *tabVC;

@property (nonatomic, weak) LoaderChildViewController* child;
@property (nonatomic, retain) LoaderViewController *loader;
-(void)loadWithItem:(NSDictionary*)item url:(NSURL*)url;

-(instancetype)initWithLoaderChild:(LoaderChildViewController*)child;
@end
