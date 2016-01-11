//
//  RemoteCache.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 24/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "RemoteAppCache.h"
#import "LZMASDK/LZMAExtractor.h"
#import "NSString+URLEncoding.h"
#import "AppDeck.h"
#import "AppURLCache.h"
#import "ManagedUIWebViewController.h"
#import "LoaderViewController.h"
#import "AppDeckAnalytics.h"

@implementation RemoteAppCache

-(id)initWithURL:(NSURL *)_url andTTL:(float)_seconds
{
    self = [super init];

    url = _url;
    ttl = _seconds;
    backgroundQueue = dispatch_queue_create("com.mobideck.cache.bgqueue", NULL);
    timer = [NSTimer scheduledTimerWithTimeInterval:ttl target:self selector:@selector(downloadAppCache:) userInfo:nil repeats:YES];
    self.state = RemoteAppCacheStateWait;
    [timer fire];
//    [self downloadAppCache:nil];
    
    return self;
}

-(void)dealloc
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
}

int main_unused_7z(int numargs, char *args[]);

-(void)downloadAppCache:(id)sender
{
    if (self.state == RemoteAppCacheStateWork)
        return;
    
    self.state = RemoteAppCacheStateWork;
    self.lastFetchNbCreate = 0;
    self.lastFetchNbUpdate = 0;
    dispatch_async(backgroundQueue, ^(void) {

        
        [RemoteAppCache sync:url nbCreate:&_lastFetchNbCreate nbUpdate:&_lastFetchNbUpdate];

        // add some statistics
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDeck *appDeck = [AppDeck sharedInstance];
//            [appDeck.loader.globalTracker trackEventWithCategory:@"prefetch" withAction:@"finished" withLabel:url.absoluteString withValue:[NSNumber numberWithInt:1]];
            
            [appDeck.loader.analytics sendEventWithName:@"prefetch" action:@"finished" label:url.absoluteString value:[NSNumber numberWithInt:1]];
            
            self.state = RemoteAppCacheStateWait;
        });
        
    });
}

+(void)sync:(NSURL *)url nbCreate:(int *)lastFetchNbCreate nbUpdate:(int *)lastFetchNbUpdate
{
    NSURLResponse *cacheResponse;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:&cacheResponse error:&error];
    
    if (data == nil || data.length == 0)
        return;
    
    //CLSNSLog(@"remoteCache data receive, length: %d", data.length);
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cacheFile = [cachePath stringByAppendingPathComponent:@"cache.7z"];
    [[NSFileManager defaultManager] removeItemAtPath:cacheFile error:nil];
    [data writeToFile:cacheFile atomically:YES];
    
    NSArray *contents = [LZMAExtractor extract7zArchive:cacheFile tmpDirName:@"7z"];
    
    AppDeck *appDeck = [AppDeck sharedInstance];
    
    for (NSString *entryPath in contents)
    {
        NSURL *fileURL = [NSURL fileURLWithPath:entryPath];
        NSString *fileName = [fileURL.pathComponents lastObject];
        NSString *rurlString = [NSString stringWithFormat:@"http://%@", [fileName urlDecodeUsingEncoding:NSUTF8StringEncoding]];
        
        NSURL *rurl = [NSURL URLWithString:rurlString];
        if (rurl == nil)
            continue;
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:rurl];
        
        // make some stats
        NSDate *date = nil;
        if ([appDeck.cache requestIsInCache:request date:&date] == NO)
            *lastFetchNbCreate = *lastFetchNbCreate + 1;
        else
            *lastFetchNbUpdate = *lastFetchNbUpdate + 1;        
        
        //BOOL isInCache = [app.cache requestIsInCache:request date:&date];
        if (YES)//[app.cache requestIsInCache:request date:&date] == NO)
        {
            NSData *rdata = [NSData dataWithContentsOfFile:entryPath];
            NSString *MIMEType = @"text/html";
            NSString *textEncodingName = nil;
            
            /*
            // inject appdeck js in data ?
            if ([ManagedUIWebViewController shouldInjectAppDeckJSInData:rdata])
            {
                //NSLog(@"patch remote %@", request);
                NSData *patched_data = [ManagedUIWebViewController dataWithInjectedAppDeckJS:rdata];
                if (patched_data)
                    rdata = patched_data;
            }*/
            
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:MIMEType expectedContentLength:[rdata length] textEncodingName:textEncodingName];
            NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:rdata];
            
            @try {
                [appDeck.cache storeToDiskCacheResponse:cachedResponse forRequest:request];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            
            //NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:entryPath error:nil];
            //NSLog(@"New Cache Entry: %@ : %lu - %@", request.URL.relativePath, [rdata length], [dic objectForKey:NSFileSize]);
            
            [[NSFileManager defaultManager] removeItemAtPath:entryPath error:nil];
#ifdef DEBUG_OUTPUT
            NSLog(@"New Cache Entry: %@", request.URL.relativePath);
#endif
            
        }
    }
}

@end


