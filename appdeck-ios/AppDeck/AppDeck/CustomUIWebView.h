//
//  CustomUIWebView.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 24/09/14.
//  Copyright (c) 2012 Mobideck. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDeckApiCall;

@interface myWebDataSource : NSObject

- (NSData *)data;
- (NSURL *)URL;
- (NSString *)MIMEType;
- (NSString *)textEncodingName;
- (NSString *)frameName;
- (void)addSubresource:(id)subresource;
- (BOOL)isLoading;
@end

@protocol CustomUIWebViewProgressDelegate <NSObject>
- (void) webView:(UIWebView*)webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources;
- (void) webView:(UIWebView*)webView didFailReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources withError:(id)error;
- (void) webView:(UIWebView*)webView willLoadFrameRequest:(NSURLRequest *)request;

@property (nonatomic, assign) int resourceCount;
@property (nonatomic, assign) int resourceCompletedCount;
@property (strong) id webDataSource;

@optional
- (NSString *)webView:(UIWebView *)webView runPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame;

@end

@interface CustomUIWebView : UIWebView
{
}

@property (nonatomic, assign) BOOL frameLoad;

@property (nonatomic, assign) int resourceCount;
@property (nonatomic, assign) int resourceCompletedCount;

@property (nonatomic, assign) IBOutlet id<CustomUIWebViewProgressDelegate> progressDelegate;

@end
