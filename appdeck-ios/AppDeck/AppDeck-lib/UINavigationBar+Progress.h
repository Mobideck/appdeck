//
//  UINavigationBar+Progress.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 03/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Progress)

/*-(void)setProgressAtInitialState;
-(void)setProgressHidden:(BOOL)hidden animated:(BOOL)animated;
-(void)setProgress:(float)progress animated:(BOOL)animated delay:(float)delay;*/

-(void)progressStart:(float)expectedProgress inTime:(float)duration;
-(void)progressUpdate:(float)progress duration:(float)duration;
-(void)progressEnd:(float)duration;

@end
