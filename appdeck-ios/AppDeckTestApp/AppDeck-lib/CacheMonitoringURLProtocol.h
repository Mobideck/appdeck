//
//  CacheMonitoringURLProtocol.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 15/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheMonitoringURLProtocol : NSURLProtocol <NSURLConnectionDelegate>
{
    //ManagedUIWebViewController *ctl;
    NSUInteger expectedContentLength;
    NSUInteger receivedContentLength;
        
    BOOL        shouldCache;
    BOOL        shouldCDN;
}

@property (nonatomic, readwrite, strong) NSMutableURLRequest *MyRequest;
@property (nonatomic, readwrite, strong) NSURLConnection *MyConnection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;

@end
