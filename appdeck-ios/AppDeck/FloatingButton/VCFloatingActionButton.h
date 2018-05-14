//
//  VCFloatingActionButton.h
//  starttrial
//
//  Created by Giridhar on 25/03/15.
//  Copyright (c) 2015 Giridhar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoaderChildViewController.h"
#import "LoaderViewController.h"


@protocol floatMenuDelegate <NSObject>

@optional
-(void) didSelectMenuOptionAtIndex:(NSInteger)row;
@end


@interface VCFloatingActionButton : UIView <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, weak) LoaderChildViewController* child;
@property (nonatomic, weak) LoaderViewController* loader;
@property (nonatomic, retain) AppDeckApiCall*call;
@property NSArray      *imageArray,*labelArray,*buttonsArray;
@property UITableView  *menuTable;
@property UIView       *buttonView;
@property id<floatMenuDelegate> delegate;

@property (nonatomic) BOOL hideWhileScrolling;

@property (strong,nonatomic) UIView *bgView;
@property (strong,nonatomic) UIScrollView *bgScroller;
@property (strong,nonatomic) UIImageView *normalImageView,*pressedImageView;
//@property (strong,nonatomic) UIWindow *mainWindow;
@property (strong,nonatomic) UIImage *pressedImage, *normalImage;
@property (strong,nonatomic) NSDictionary *menuItemSet;


@property BOOL isMenuVisible;
//@property UIView *windowView;

-(id)initWithFrame:(CGRect)frame normalImage:(UIImage*)passiveImage andPressedImage:(UIImage*)activeImage withScrollview:(UIScrollView*)scrView;
//-(void) setupButton;


@end
