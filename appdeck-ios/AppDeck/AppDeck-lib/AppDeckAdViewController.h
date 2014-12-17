//
//  AppDeckAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AdManager;
@class AppDeckAdEngine;
@class LoaderChildViewController;
@class AdRation;

typedef enum AppDeckAdState: int {
    AppDeckAdStateEmpty = 0,
    AppDeckAdStateReady = 1,
    AppDeckAdStateFailed = 2,
    AppDeckAdStateCancel = 3,
    AppDeckAdStateLoad = 4,
    AppDeckAdStateAppear = 5,
//    AppDeckAdStateDisappear = 6, // TODO: remove
//    AppDeckAdStateUnload = 7, // TODO: remove
    AppDeckAdStateClose = 8
} AppDeckAdState;

@interface AppDeckAdViewController : UIViewController

- (id)initWithAdRation:(AdRation *)adRation engine:(AppDeckAdEngine *)adEngine config:(NSDictionary *)config;

-(void)adIsReady;

-(void)adDidFailed;

-(void)adDidCancel;

-(void)adWillLoadInViewController:(LoaderChildViewController *)ctl;

-(void)adWillAppearInViewController:(LoaderChildViewController *)ctl;

-(void)adWillDisappearInViewController:(LoaderChildViewController *)ctl;

-(void)adDidUnloadFromViewController:(LoaderChildViewController *)ctl;

-(void)cancel;

@property (nonatomic, assign) AppDeckAdState state;

@property (nonatomic, strong)   AdRation  *adRation;
@property (nonatomic, strong)   AppDeckAdEngine  *adEngine;
@property (nonatomic, strong)   NSDictionary  *adConfig;

@property (nonatomic, weak)   LoaderChildViewController  *page;

@property (nonatomic, assign)   float  width;
@property (nonatomic, assign)   float  height;

// deprecated
// TODO: remove

//- (id)initWithAdManager:(AdManager *)adManager type:(NSString *)adType engine:(AppDeckAdEngine *)engine;

@property (nonatomic, strong)   NSString  *adType;
@property (nonatomic, strong)   AdManager  *adManager;

@end
