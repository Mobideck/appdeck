//
//  ManagedWebViewURLProtocol.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 28/02/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ManagedUIWebViewController;

@interface ManagedUIWebViewURLProtocol : NSURLProtocol <NSURLConnectionDelegate>
{    
    ManagedUIWebViewController *ctl;
    NSUInteger expectedContentLength;
    NSUInteger receivedContentLength;
    NSMutableData *tmp;
}

@property (nonatomic, readwrite, strong) NSMutableURLRequest *myRequest;
@property (nonatomic, readwrite, strong) NSURLConnection *myConnection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;

@end
