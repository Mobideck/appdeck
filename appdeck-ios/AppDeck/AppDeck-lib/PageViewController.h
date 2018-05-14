//
//  pageViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 15/12/12.
//  Copyright (c) 2012 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>
#import "CustomUIWebView.h"
#import "MBProgressHUD.h"
#import "UIImageView+Animation.h"
#import "ManagedWebView.h"
#import "LoaderChildViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDeckAdViewController.h"
#import "AdManager.h"

@class VCFloatingActionButton;
@interface PageViewController : LoaderChildViewController <MBProgressHUDDelegate, UIScrollViewDelegate, ManagedWebViewDelegate/*, AppDeckApiCallDelegate*/>
{    
    BOOL    loadingInprogress;
    BOOL    shouldReloadInBackground;
    BOOL    shouldAnimatedBackgroundReload;
    BOOL    shouldForceReloadInBackground;
    
    MBProgressHUD   *progressHUD;
    BOOL            progressHUDEnabled;
    
    UIImageView *pullTorefreshArrow;
    UIImageView *pullTorefreshLoading;
    
    float       pullLoadingPercent;
    
    NSDate  *lastUpdate;
    
    ManagedWebView *contentCtl;
    ManagedWebView *refreshCtl;
       
    BOOL    shouldReloadHistory;
    
    NSTimer *timer;
    
    UIView *errorView;
    UIImageView *errorImageView;
    
    long    lastScrollToBottomEventTime;
    float   lastScrollToBottomEventContentHeight;
    NSTimeInterval     scrollToBottomEventTimeInterval;
    
    
    BOOL                        bannerAdAnimating;
    
    BOOL wasLandscape;
    
    BOOL    shouldPatchContentInset;
    
    BOOL    showLoading;
    
    BOOL keyboardWasVisible;
    
    NSMutableDictionary *nativeAds;
}

@property (strong, nonatomic) UIWebView *header;
@property (strong, nonatomic) UIWebView *footer;



@property (assign, nonatomic) BOOL          showAdView;
@property (assign, nonatomic) BOOL          showAdViewOver;

//@property (strong, nonatomic)     AppDeckAdViewController   *interstitialAd;
@property (strong, nonatomic)     AppDeckAdViewController   *rectangleAd;
@property (strong, nonatomic)     AppDeckAdViewController   *bannerAd;
@property (strong, nonatomic)     NSString                  *tagAd;

-(UIView *)webView;

@end
