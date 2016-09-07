//
//  AppDeckProgressHUD.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 18/12/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppDeckProgressHUD : NSObject

@property (nonatomic, weak)UIViewController *viewController;

+ (AppDeckProgressHUD *)progressHUDForViewController:(UIViewController *)viewController;

//-(void)setDeterminate:(BOOL)determinate;

-(void)show;
-(void)hide;

@property (assign) float graceTime;
@property (assign) float minShowTime;

@end
