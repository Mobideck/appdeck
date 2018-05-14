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
#import "LoaderViewController.h"
#import "AppDeckAnalytics.h"
#import "LogViewController.h"

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
    dispatch_async(backgroundQueue, ^(void)
    {

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
    AppDeck *appDeck = [AppDeck sharedInstance];
    NSFileManager *fileManager = NSFileManager.defaultManager;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error)
    {
                                      
                                      
                    if (data == nil || data.length == 0)
                    return;
        
                    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                    NSString *cacheFile = [cachePath stringByAppendingPathComponent:@"cache.7z"];
                    [fileManager removeItemAtPath:cacheFile error:nil];
                    [data writeToFile:cacheFile atomically:YES];
        
                    NSArray *contents = [LZMAExtractor extract7zArchive:cacheFile tmpDirName:@"7z"];
        
                    for (NSString *entryPath in contents)
                    {
                        NSURL *fileURL = [NSURL fileURLWithPath:entryPath];
                        NSString *fileName = [fileURL.pathComponents lastObject];
                        BOOL isMeta = NO;
                        if ([fileName hasSuffix:@".meta"])
                        {
                            isMeta = YES;
                            fileName = [fileName substringToIndex:fileName.length-5];
                        }
                        NSString *rurlString = [NSString stringWithFormat:@"http://%@", [fileName urlDecodeUsingEncoding:NSUTF8StringEncoding]];
                        
                        NSURL *rurl = [NSURL URLWithString:rurlString];
                        if (rurl == nil)
                        continue;
                        
                        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:rurl];
                        
                        if (isMeta == NO)
                        {
                            // make some stats
                            NSDate *date = nil;
                            if ([appDeck.cache requestIsInCache:request date:&date] == NO)
                            *lastFetchNbCreate = *lastFetchNbCreate + 1;
                            else
                            *lastFetchNbUpdate = *lastFetchNbUpdate + 1;
                        }
                        
                        NSString *targetPath = [appDeck.cache getCachePathForRequest:request];
                        
                        if (isMeta)
                        targetPath = [targetPath stringByAppendingString:@".meta"];
                        else
                        targetPath = [targetPath stringByAppendingString:@".body"];
                        
                        [fileManager removeItemAtPath:targetPath error:&error];
                        if ([fileManager moveItemAtPath:entryPath toPath:targetPath error:&error] == NO)
                        NSLog(@"RemoteAppCache: failed to move %@ to %@: %@", fileName, cachePath, error);
                        
                        NSLog(@"RemoteAppCache: %@ => %@", rurlString, targetPath);
                        
                        if (glLog)
                        [glLog debug:@"New Cache Entry: %@", request.URL.relativePath];
                    }
        
                    if (glLog)
                    [glLog debug:@"Content Synchronization: %d create - %d update", *lastFetchNbCreate, *lastFetchNbUpdate];
                                      
                                      
    }];
    
    [task resume];
    
 
}

@end


