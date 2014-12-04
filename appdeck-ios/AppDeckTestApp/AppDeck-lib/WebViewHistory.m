//
//  WebViewHistory.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 14/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "WebViewHistory.h"

#import <objc/message.h>

@implementation WebViewHistory

#pragma mark - WebView History

+(NSString *)getWebViewHistoryPath
{
    static NSString *documentPath = nil;
    // This stores in the Caches directory, which can be deleted when space is low, but we only use it for offline access
    if (documentPath == nil)
        documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [documentPath stringByAppendingPathComponent:@"webview.history"];    
}

+(MyWebHistory *)sharedInstance
{
    static MyWebHistory *obj = nil;
    
    if (obj == nil)
    {
//        obj = (MyWebHistory *)[NSClassFromString(@"WebHistory") optionalSharedHistory];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        //obj = (MyWebHistory *)[NSClassFromString(@"WebHistory") performSelector:NSSelectorFromString(@"optionalSharedHistory")];
#pragma clang diagnostic pop
        
        obj = (MyWebHistory *)objc_msgSend(NSClassFromString(@"WebHistory"), NSSelectorFromString(@"optionalSharedHistory"));

        
        //NSLog(@"History Obj: %@", [[obj class] description]);
        if ([[[obj class] description] isEqualToString:@"WebHistory"] == NO)
        {
            obj = nil;
            return nil;
        }
        if (obj == nil)
            return nil;
        NSString *dataPath = [WebViewHistory getWebViewHistoryPath];
//        MyWebHistory *obj = (MyWebHistory *)[NSClassFromString(@"WebHistory") optionalSharedHistory];
//        NSError *error = nil;
        
        //obj performSelector:NSSelectorFromString(@"optionalSharedHistory")

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [obj performSelector:NSSelectorFromString(@"loadFromURL:error:") withObject:[[NSURL alloc] initFileURLWithPath:dataPath] withObject:nil];
#pragma clang diagnostic pop
        
        /*BOOL ret = [obj loadFromURL:[[NSURL alloc] initFileURLWithPath:dataPath] error:&error];
        if (ret == NO)
        {
            NSLog(@"loadWebViewHistory failed %@", error);
        }*/
    }
    return obj;
}

+(void)saveWebViewHistory:(UIWebView *)webView
{
    NSString *dataPath = [WebViewHistory getWebViewHistoryPath];

    MyWebHistory *obj = [WebViewHistory sharedInstance];
    
//    NSError *error = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [obj performSelector:NSSelectorFromString(@"saveToURL:error:") withObject:[[NSURL alloc] initFileURLWithPath:dataPath] withObject:nil];
#pragma clang diagnostic pop
    
//    [obj saveToURL:[[NSURL alloc] initFileURLWithPath:dataPath]  error:&error];
    /*
    MyWebHistory *newobj = (MyWebHistory *)objc_msgSend(NSClassFromString(@"WebHistory"), NSSelectorFromString(@"alloc"));
    [newobj loadFromURL:[[NSURL alloc] initFileURLWithPath:dataPath] error:&error];
    
    [NSClassFromString(@"WebHistory") performSelector:NSSelectorFromString(@"setOptionalSharedHistory") withObject:newobj];
    */
//    objc_msgSend(NSClassFromString(@"WebHistory"), NSSelectorFromString(@"setOptionalSharedHistory"));
    
/*    //
    NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.cache storeCachedResponse:cachedResponse forRequest:request];
  */
}

+(BOOL)inHistory:(NSURL *)url lastVisited:(NSTimeInterval *)lastVisited
{
    MyWebHistory *obj = [WebViewHistory sharedInstance];
    id myWebHistoryItem = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    myWebHistoryItem = [obj performSelector:NSSelectorFromString(@"itemForURL:") withObject:url];
#pragma clang diagnostic pop
    if (myWebHistoryItem == nil)
        return NO;
    SEL selector = NSSelectorFromString(@"lastVisitedTimeInterval");
    if ([myWebHistoryItem respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [[myWebHistoryItem class] instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:myWebHistoryItem];
        [invocation invoke];
        if (lastVisited)
            [invocation getReturnValue:lastVisited];
        return YES;
    }
    return NO;
/*
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    *lastVisited = objc_msgSend_fpret(myWebHistoryItem, NSSelectorFromString(@"lastVisitedTimeInterval"));//(int)[myWebHistoryItem performSelector:NSSelectorFromString(@"lastVisitedTimeInterval")];
#pragma clang diagnostic pop
    return YES;*/
}

@end
