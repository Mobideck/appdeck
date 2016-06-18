//
//  AppDeckApiCall.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 14/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDeck;
@class LoaderViewController;
@class SwipeViewController;
@class LoaderChildViewController;
@class ManagedWebView;

@interface AppDeckApiCall : NSObject

@property (strong, nonatomic) NSString *command;
@property (strong, nonatomic) NSString *eventID;
@property (strong, nonatomic) NSString *inputJSON;
@property (strong, nonatomic) NSDictionary *input;
@property (strong, nonatomic) id param;
@property (strong, nonatomic) NSString *resultJSON;
@property (strong, nonatomic) id result;
@property (assign, nonatomic) BOOL success;
@property (assign, nonatomic) BOOL callBackSend;
@property (strong, nonatomic) AppDeck *app;
@property (strong, nonatomic) LoaderViewController *loader;
@property (strong, nonatomic) SwipeViewController *container;
@property (strong, nonatomic) LoaderChildViewController *child;
@property (strong, nonatomic) ManagedWebView *managedWebView;
@property (strong, nonatomic) UIView *origin;
//@property (strong, nonatomic) UIWebView *webview;
@property (strong, nonatomic) NSURL *baseURL;
@property (readonly, nonatomic) NSString *jsTarget;

-(void)sendCallBackWithErrorMessage:(NSString *)errorMessage;
-(void)sendCallBackWithError:(NSError *)error;
-(void)sendCallbackWithResult:(NSArray *)result;

@end

@protocol AppDeckApiCallDelegate <NSObject>

@optional
- (BOOL) apiCall:(AppDeckApiCall *)call;

@end