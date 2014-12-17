//
//  MobilizeViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 21/02/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MobilizeViewController.h"
#import "NSString+URLEncoding.h"
#import "UINavigationBar+Progress.h"
#import "SwipeViewController.h"

@interface MobilizeViewController ()

@end

@implementation MobilizeViewController

-(NSURLRequest *)getRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [NSURLProtocol setProperty:self forKey:@"MobilizeUIWebViewURLProtocol" inRequest:request];
    return request;
}

@end
