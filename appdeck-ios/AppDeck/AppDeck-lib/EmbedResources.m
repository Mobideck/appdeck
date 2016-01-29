//
//  EmbedResources.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/04/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "EmbedResources.h"
#import "AppDeck.h"
#import "AppURLCache.h"

@implementation EmbedResources

-(id)initWithURL:(NSURL *)url shouldOverrideEmbedResource:(BOOL)override downloadInBackground:(BOOL)async
{
    cancel = NO;
    self.url = url;
    self.override = override;
    self.async = async;
    //
    //[self sync];
    
    return self;
}

-(void)sync
{
    AppDeck *appDeck = [AppDeck sharedInstance];
    // prefetch disabled in user profile ?
    if (appDeck.userProfile.enable_prefetch == NO)
        return;
    
    if (self.async)
    {
        conn = [[NSURLConnection alloc] initWithRequest:[[NSMutableURLRequest alloc] initWithURL:self.url] delegate:self startImmediately:YES];
        if (conn)
        {
            receivedData = [NSMutableData data];
        }
    }
    else
    {
        NSError *error;
        NSURLResponse *response;
        NSData *data = [NSURLConnection sendSynchronousRequest:[[NSMutableURLRequest alloc] initWithURL:self.url] returningResponse:&response error:&error];
        [self syncFromData:data];
    }
}

-(void)cancel
{
    if (conn)
    {
        [conn cancel];
        conn = nil;
    }
    cancel = YES;
}

-(void)dealloc
{
    [self cancel];
}

#pragma mark - ressource sync

-(void)syncFromData:(NSData *)linesData
{
    AppDeck *appDeck = [AppDeck sharedInstance];
    NSDate *date;
    
    NSString *content = [[NSString alloc]  initWithBytes:[linesData bytes] length:[linesData length] encoding: NSUTF8StringEncoding];
    
    NSArray* lines = [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    NSInteger nb_files = 0;
    NSInteger nb_files_new = 0;
    
    for (NSString *line in lines)
    {
        nb_files++;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:line]];
        
        if (self.override == NO && [appDeck.cache requestIsInEmbedCache:request] == YES)
            continue;
        if ([appDeck.cache requestIsInCache:request date:&date] == NO)
        {
            nb_files_new++;
            // prevent cache monitoring
            [NSURLProtocol setProperty:@"set" forKey:@"CacheMonitoringURLProtocol" inRequest:request];
            NSError *error;
            NSURLResponse *response;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (data && response)
            {
                NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                [appDeck.cache storeToDiskCacheResponse:cachedResponse forRequest:request];
            }
        }
    }
    
    NSLog(@"Sync Embed Resources from %@ OK : %ld urls - %ld new", self.url.relativePath, (long)nb_files, (long)nb_files_new);
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0]; 
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
     [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    conn = nil;
    
    __block EmbedResources *me = self;
    __block NSMutableData *myReceivedData = receivedData;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [me syncFromData:myReceivedData];
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    conn = nil;
    
    
}

@end
