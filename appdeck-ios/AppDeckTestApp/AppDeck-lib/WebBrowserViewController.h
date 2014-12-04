//
//  WebBrowserViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "LoaderChildViewController.h"
#import "ManagedUIWebViewController.h"

@class PageBarButton;

@interface WebBrowserViewController : LoaderChildViewController <ManagedUIWebViewDelegate, UIScrollViewDelegate>
{
    PageBarButton *buttonRefresh;
    PageBarButton *buttonCancel;
    PageBarButton *buttonPrevious;
    PageBarButton *buttonNext;
    PageBarButton *buttonAction;
    
    NSTimer *timer;    
}

@property (nonatomic, strong)   ManagedUIWebViewController   *content;

-(NSURLRequest *)getRequest;

@end
