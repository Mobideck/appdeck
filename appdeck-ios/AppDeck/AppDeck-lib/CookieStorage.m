//
//  CookieStorage.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 11/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "CookieStorage.h"

@implementation CookieStorage

+(NSString *)getCookieStoragePath
{
    static NSString *cachesPath = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        // This stores in the Caches directory, which can be deleted when space is low, but we only use it for offline access
        cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        cachesPath = [cachesPath stringByAppendingPathComponent:@"cookie.storage"];
    });
    
    return cachesPath;
}

+(void)saveCookies
{
    __block NSArray* allCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [NSKeyedArchiver archiveRootObject:allCookies toFile:[CookieStorage getCookieStoragePath]];
    });
}

+(void)loadCookies
{
    NSHTTPCookieStorage *sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithFile:[CookieStorage getCookieStoragePath]];
    for (NSHTTPCookie *cookie in cookies)
    {
        [sharedCookieStorage setCookie:cookie];
    }
}

+(void)dumpCookies
{
    return;
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        NSLog(@"Cookie: %@", cookie);
    }
}

@end
