//
//  LoaderChildViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 04/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDeckApiCall.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LoaderViewController.h"

//#import "PopUpVideoViewController.h"
@class LoaderViewController;
@class SwipeViewController;
@class ScreenConfiguration;
@class PageBarButtonContainer;
@class AdRequest;

@protocol AppDeckApiCallDelegate;

@interface LoaderChildViewController : UIViewController <AppDeckApiCallDelegate>
{
//        MPMoviePlayerController *player;
//    PopUpVideoViewController *video;
}
@property (nonatomic, assign)   BOOL   progressStart; // progress going one
@property (nonatomic, assign)   BOOL   progressIndeterminate; // only fisrt step
//@property (nonatomic, assign)   float   progressHidden;
@property (nonatomic, assign)   float   progress; // current progress step
@property (nonatomic, assign)   BOOL showProgress;

@property (nonatomic, weak)       LoaderViewController *loader;
@property (nonatomic, weak)       SwipeViewController *swipeContainer;

//@property (nonatomic, assign) NSInteger swipeIndex;

@property (assign)              BOOL    isVisible;
@property (assign)              BOOL    isPopUp;

@property (assign, nonatomic)   BOOL isFullScreen;

@property (assign, nonatomic, readonly) BOOL isMain;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURL *nextUrl;
@property (strong, nonatomic) NSURL *previousUrl;


@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) UIView *focus;

@property (strong, nonatomic) ScreenConfiguration    *screenConfiguration;

@property (strong, nonatomic) LoaderChildViewController *parent;

@property (strong, nonatomic) NSArray *rightBarButtonItems;

@property (assign, nonatomic)              BOOL    disableAds;
@property (assign, nonatomic)              BOOL    isReadyForAds;
@property (assign, nonatomic)               AdManagerEvent adEvent;
@property (strong, nonatomic) AdRequest     *adRequest;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil URL:(NSURL *)url content:(UIWebView *)content header:(UIWebView *)headerOrNil footer:(UIWebView *)footerOrNil loader:(LoaderViewController *)loader;

-(void)shouldReloadHistory;

-(void)childIsMain:(BOOL)isMain;

//-(BOOL)call:(NSString *)command origin:(UIView *)origin;

-(BOOL)apiCall:(AppDeckApiCall *)call;

-(void)load:(NSString *)url;

-(NSString *)executeJS:(NSString *)js;

-(void)reload;
//-(void)playAdVideo;

//-(void)playPopUpAdVideo;

- (void)progressEstimateChanged:(NSNotification*)theNotification;

@end
