//
//  CustomUIWebView.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 24/09/14.
//  Copyright (c) 2012 Mobideck. All rights reserved.
//

#import "CustomUIWebView.h"
#import "AppDeck.h"
#import "AppDeckApiCall.h"

@implementation UIWebView (withProgress)

- (void)altwebView:(id)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(id)frame decisionListener:(id)listener
{
    if (self.delegate!= nil && [self.delegate respondsToSelector:@selector(webView:willLoadFrameRequest:)])
    {
        id mainFrame = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        mainFrame = [webView performSelector:NSSelectorFromString(@"mainFrame")];
#pragma clang diagnostic pop
        
        if (frame != mainFrame)
        {
            id<CustomUIWebViewProgressDelegate> progressDelegate = (id<CustomUIWebViewProgressDelegate>)self.delegate;
            [progressDelegate webView:self willLoadFrameRequest:request];
        }
    }

    [self altwebView:webView decidePolicyForNavigationAction:actionInformation request:request frame:frame decisionListener:listener];
    

}

-(id)altwebView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource
{
    id identifier = [self altwebView:view identifierForInitialRequest:initialRequest fromDataSource:dataSource];
    if (self.delegate!= nil && [self.delegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)])
    {
        id<CustomUIWebViewProgressDelegate> progressDelegate = (id<CustomUIWebViewProgressDelegate>)self.delegate;
        progressDelegate.resourceCount++;
        progressDelegate.webDataSource = dataSource;
    }
    return identifier;
}

- (void)altwebView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource
{
    [self altwebView:view resource:resource didFailLoadingWithError:error fromDataSource:dataSource];
    if (self.delegate!= nil && [self.delegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)])
    {
        id<CustomUIWebViewProgressDelegate> progressDelegate = (id<CustomUIWebViewProgressDelegate>)self.delegate;
        progressDelegate.resourceCompletedCount++;
        [progressDelegate webView:self didFailReceiveResourceNumber:progressDelegate.resourceCompletedCount totalResources:progressDelegate.resourceCount withError:error];
        
    }
}

-(void)altwebView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource
{
    [self altwebView:view resource:resource didFinishLoadingFromDataSource:dataSource];
    if (self.delegate!= nil && [self.delegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)])
    {
        id<CustomUIWebViewProgressDelegate> progressDelegate = (id<CustomUIWebViewProgressDelegate>)self.delegate;
        progressDelegate.resourceCompletedCount++;
        [progressDelegate webView:self didReceiveResourceNumber:progressDelegate.resourceCompletedCount totalResources:progressDelegate.resourceCount];
    }
}


- (NSString *)altwebView:(id)sender runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame
{
    if ([prompt hasPrefix:@"appdeckapi:"])
    {
        if (self.delegate!= nil && [self.delegate respondsToSelector:@selector(apiCall:)])
        {
            AppDeckApiCall *call = [[AppDeckApiCall alloc] init];
            call.app = [AppDeck sharedInstance];
            call.webview = self;
            call.command = [prompt substringFromIndex:11];
            call.inputJSON = defaultText;
            id<AppDeckApiCallDelegate> apiDelegate = (id<AppDeckApiCallDelegate>)self.delegate;
            BOOL success = [apiDelegate apiCall:call];
            
            if (success == NO)
                NSLog(@"API unsuported command: %@", call.command);
            
            NSString *ret = [NSString stringWithFormat:@"{\"success\": \"%d\", \"result\": %@}", success, call.resultJSON];
            return ret;
        }
        else
        {
            NSLog(@"lost API CALL: %@", prompt);
            return @"";
        }

    }
    return [self altwebView:sender runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame];    
    if ([prompt hasPrefix:@"toto"])
    {
        NSLog(@"%@", defaultText);
        return @"";
    }
    if ([prompt hasPrefix:@"event:"])
    {
        if (self.delegate!= nil && [self.delegate respondsToSelector:@selector(webView:runPrompt:defaultText:initiatedByFrame:)])
        {
            id<CustomUIWebViewProgressDelegate> progressDelegate = (id<CustomUIWebViewProgressDelegate>)self.delegate;
            return [progressDelegate webView:self runPrompt:prompt defaultText:defaultText initiatedByFrame:frame];
        }
    }
    else
    {
        return [self altwebView:sender runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame];
    }
    return @"";
}

@end
