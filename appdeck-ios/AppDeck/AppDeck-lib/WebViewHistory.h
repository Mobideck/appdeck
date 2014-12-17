//
//  WebViewHistory.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 14/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyWebHistory : NSObject

+(MyWebHistory *)optionalSharedHistory;
//+(void)setOptionalSharedHistory:(MyWebHistory *)history;

//- (BOOL)saveToURL:(NSURL *)URL error:(NSError **)error;
//- (BOOL)loadFromURL:(NSURL *)URL error:(NSError **)error;
@end

@interface WebViewHistory : NSObject

+(void)saveWebViewHistory:(UIWebView *)webView;
+(MyWebHistory *)sharedInstance;

+(BOOL)inHistory:(NSURL *)url lastVisited:(NSTimeInterval *)lastVisited;
@end
