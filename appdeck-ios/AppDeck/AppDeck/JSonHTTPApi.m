//
//  JSonHTTPApi.m
//  reddit
//
//  Created by Mathieu De Kermadec on 03/11/12.
//  Copyright (c) 2012 Mathieu De Kermadec. All rights reserved.
//

#import "JSonHTTPApi.h"
#import "NSString+URLEncoding.h"
#import "JSONKit.h"

@implementation JSonHTTPApi

- (id)initWithURL:(NSString *)url params:(NSDictionary * )params
                     callback: ( JSonHTTPApiCallBack )callback
{
  	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    if (params)
    {
        NSString *datastring = [self encodeParams:params];
        NSData *data = [datastring dataUsingEncoding: NSUTF8StringEncoding];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: data];
    }
    return [self initWithRequest:request callback:callback];
}

-(NSString *)encodeParams:(NSDictionary *)params
{
    __block NSString *datastring = [[NSMutableString alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *value, BOOL *stop)
     {
         datastring = [datastring stringByAppendingFormat:@"%@%@=%@",
                       ([datastring length] == 0 ? @"" : @"&"),
                       [name urlEncodeUsingEncoding:NSUTF8StringEncoding], [value urlEncodeUsingEncoding:NSUTF8StringEncoding]];
     }];
    return datastring;
}

/*
-(void)urlEncode:(NSDictionary *)params target:(NSMutableString **)target path:(NSString *)path
{
    NSMutableString *datastring = *target;
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *name, id value, BOOL *stop)
     {
         if ([value isKindOfClass:[NSString class]])
         {
             NSString *stringValue = (NSString *)value;
             [datastring stringByAppendingFormat:@"%@%@=%@",
                           ([datastring length] == 0 ? @"" : @"&"),
                           [name urlEncodeUsingEncoding:NSUTF8StringEncoding], [value urlEncodeUsingEncoding:NSUTF8StringEncoding]];
         }
         if ([value isKindOfClass:[NSDictionary class]])
         {
             NSDictionary *dictValue = (NSDictionary *)value;
             
             [self urlEncode:dictValue target:target path:[NSString stringWithFormat:@"%@[%@]", path, [name urlEncodeUsingEncoding:NSUTF8StringEncoding]]];
         }
         datastring = [datastring stringByAppendingFormat:@"%@%@=%@",
                       ([datastring length] == 0 ? @"" : @"&"),
                       [name urlEncodeUsingEncoding:NSUTF8StringEncoding], [value urlEncodeUsingEncoding:NSUTF8StringEncoding]];
     }];
    *target = datastring;
}*/

-(NSMutableURLRequest *)prepareRequest:(NSURLRequest *)request
{
    
    
    
    return [request mutableCopy];
}

- (id)initWithRequest:(NSURLRequest *)request callback: ( JSonHTTPApiCallBack )callback
{
    self = [super init];
    
    if (self)
    {
        self.callback = callback;
        self.request = [self prepareRequest:request];
        
        conn = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
        if (conn)
        {
            receivedData = [NSMutableData data];
        }
        else
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"No Network Available" forKey:NSLocalizedDescriptionKey];
            callback(nil, [NSError errorWithDomain:@"appdeck" code:100 userInfo:errorDetail]);
        }
    }
    return self;
}

+ ( JSonHTTPApi * )apiWithURL:(NSString *)url params:(NSMutableDictionary * )params
                     callback: ( JSonHTTPApiCallBack )callback
{
    JSonHTTPApi *api = [[JSonHTTPApi alloc] initWithURL:url params:params callback:callback];
    return api;
}

+ ( JSonHTTPApi * )apiWithRequest:(NSURLRequest *)request callback: ( JSonHTTPApiCallBack )callback
{
    JSonHTTPApi *api = [[JSonHTTPApi alloc] initWithRequest:request callback:callback];
    return api;
}

-(void)cancel
{
    [conn cancel];
    self.callback = nil;
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
//    NSLog(@"Succeeded! Received %lud bytes of data: %@",(unsigned long)[receivedData length], [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSError *error;

	NSMutableDictionary *result = [receivedData objectFromJSONDataWithParseOptions:JKParseOptionComments|JKParseOptionUnicodeNewlines|JKParseOptionLooseUnicode|JKParseOptionPermitTextAfterValidJSON error:&error];
    
//	NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    self.callback(result, error);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.callback(nil, error);
}




@end
