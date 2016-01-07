//
//  AdRequest.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/08/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import "AdRequest.h"
#import "AdPlacement.h"

#import "LoaderViewController.h"
#import "OpenUDID.h"
#import "SecureUDID.h"
#import "AppDeck.h"
#import "NetWorkTester.h"
#import "NSData+Zlib.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#import <AdSupport/AdSupport.h>

#define APPDECK_CARRIER_INFO_DEFAULTS_KEY   @"com.appdeck.carrierinfo"

@implementation AdRequest

-(id)initWithManager:(AdManager *)adManager page:(PageViewController *)page
{
    self = [self init];
    
    if (self)
    {
        self.adManager = adManager;
        self.page = page;
        [self fetch];
    }
    
    return self;
}

-(void)fetch
{
    NSString *adConfUrl = @"http://xad.appdeck.mobi/api/ads/template/get";
    
//    adConfUrl = @"http://oxom-cloud.seb-dev-new.paris.office.netavenir.com/api/ads/template/get";
//    adConfUrl = @"http://test.cloud.oxom.com/api/ads/template/get";
//    adConfUrl = @"http://dev.mobideck.net/test/oxomad.php";
//    adConfUrl = @"http://xad.appdeck.mobi/api/ads/template/get";
    
    NSMutableDictionary *adContext = [self getContext];//[[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *adParams = [[NSMutableDictionary alloc] init];
    [adParams setObject:adContext forKey:@"context"];
    [adParams setObject:self.adManager.loader.conf.app_api_key forKey:@"customerId"];
    
    // request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:adConfUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
    
    // params
    NSError *error;
    NSData *resultJSONData = nil;
    @try {
//         if ([NSJSONSerialization isValidJSONObject:postDataObject])
        resultJSONData = [NSJSONSerialization dataWithJSONObject:adParams options:NSJSONWritingPrettyPrinted error:&error];
        //resultJSONData = [adParams JSONDataWithOptions:JKSerializeOptionPretty|JKSerializeOptionEscapeUnicode error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"ADAPI: Exception while writing JSon: %@: %@", exception, adContext);
        return;
    }
    if (error != nil)
    {
        NSLog(@"ADAPI: Error while writing JSon: %@: %@", error, adContext);
        return;
    }
    
    //NSLog(@"JSON: %@",[[NSString alloc] initWithData:resultJSONData encoding:NSUTF8StringEncoding]);
    
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: resultJSONData];
    
    api = [JSonHTTPApi apiWithRequest:request callback:^(NSDictionary *result, NSError *error) {
        if (error != nil)
        {
            NSLog(@"AdConf Error: %@ - %@", result, error);
            self.page.adRequest = nil;
            return;
        }
        //NSLog(@"AdConf: %@ - %@", result, error);
        [self loadConfiguration:result];
        [self start];
    }];
   
}

-(void)cancel
{
    if (api)
    {
        [api cancel];
        api = NULL;
    }
    for (AdPlacement *adPlacement in self.placements)
    {
        [adPlacement cancel];
    }
    self.placements = nil;
}

-(void)dealloc
{
    [self cancel];
}

-(BOOL)loadConfiguration:(NSDictionary *)config
{
    self.config = config;
    NSDictionary *scenario = [config objectForKey:@"scenario"];
    if (scenario != nil)
        [self scenario:scenario];
    self.success = [[config objectForKey:@"success"] boolValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    self.serverRequestDate = [dateFormatter dateFromString:[config objectForKey:@"serverRequestDate"]];
    self.pageViewId = [config objectForKey:@"pageViewId"];
    NSDictionary *templateConfig = [config objectForKey:@"template"];
    if (templateConfig && [[templateConfig class] isSubclassOfClass:[NSDictionary class]])
    {
        self.templateId = [templateConfig objectForKey:@"id"];
        NSArray *placementsConfig = [templateConfig objectForKey:@"placements"];
        if (placementsConfig && [[placementsConfig class] isSubclassOfClass:[NSArray class]])
        {
            self.placements = [[NSMutableArray alloc] initWithCapacity:placementsConfig.count];
            
            for (NSDictionary *placementConfig in placementsConfig)
            {
                if (![[placementConfig class] isSubclassOfClass:[NSDictionary class]])
                    continue;
                AdPlacement *adPlacement = [[AdPlacement alloc] initWithAdrequest:self config:placementConfig];
                if (adPlacement)
                    [self.placements addObject:adPlacement];
            }
        }
    }
    
    return YES;
}

#pragma mark - request context

- (NSMutableDictionary *)getContext
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:20];

    // api version
    [params setObject:APPDECK_AD_CLOUD_VERSION forKey:@"apiVersion"];
    
    // url
    [params setObject:self.page.url.absoluteString forKey:@"url"];
    [params setObject:[self referer] forKey:@"referer"];
    
    // screen
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [params setObject:@{@"width": [NSNumber numberWithFloat:screenRect.size.width],
                        @"height": [NSNumber numberWithFloat:screenRect.size.height],
                        @"scaleFactor": [self scaleFactor],
                        @"orientation": [self orientation]
                        } forKey:@"screen"];
    
    // page
    CGRect pageRect = self.page.view.bounds;
    [params setObject:@{@"width": [NSNumber numberWithFloat:pageRect.size.width],
                        @"height": [NSNumber numberWithFloat:pageRect.size.height],
                        @"event": [AdManager AdManagerEventToString:self.page.adEvent],
                        } forKey:@"page"];
    
    // visitor
    [params setObject:@{@"id": [self oxomUDID],
                        @"openUDID": [self openUDID],
                        @"secureUDID": [self secureUDID],
                        @"udfa": [self identifier],
                        @"doNotTrack": [self doNotTrack],
                        } forKey:@"visitor"];
    
    // application
    [params setObject:@{@"identifier": [self applicationID],
                        @"version": [self applicationVersion],
                        @"build": [self applicationBuild]
                        } forKey:@"application"];
    
    // appdeck
    [params setObject:@{@"apikey": self.page.loader.conf.app_api_key,
                        @"version": APPDECK_VERSION
                        } forKey:@"appdeck"];
    
    // device
    [params setObject:@{@"type": (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"tablet" : @"phone"),
                        @"name": [self deviceName],
                        @"platform": @"ios",
                        @"language": [self language],
                        @"timeZone": [self timeZone],
                        @"carrierName": [self carrierName],
                        @"connectionType": [self connectionType],
                        @"userAgent": [[AppDeck sharedInstance] userAgent],
                        } forKey:@"device"];
    
    // geoip
    [params setObject:@{@"location": [self location],
                        @"mobileCountryCode": [self mobileCountryCode],
                        @"mobileNetworkCode": [self mobileNetworkCode],
                        @"ISOCountryCode": [self ISOCountryCode]
                        } forKey:@"geoip"];
    
    // keywords
    [params setObject:[self keywords] forKey:@"keywords"];

    
    
    return params;
}

#pragma mark - URL helper

-(NSString *)oxomUDID
{
    // TODO: implement retrieve and store of oxom ID
    return @"a000000000";
}

-(NSString *)openUDID
{
    return [OpenUDID value];
}

-(NSString *)secureUDID
{
    NSString *domain     = @"com.mobideck.appdeck";
    NSString *key        = @"JSAPI: Event: Exception while writing JSon: %@: %@";
    NSString *identifier = [SecureUDID UDIDForDomain:domain usingKey:key];
    return identifier;
}

-(NSString *)language
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (NSString *)identifier
{
    NSString *identifier = nil;
    identifier = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    return identifier;
    return [NSString stringWithFormat:@"ifa:%@", [identifier uppercaseString]];
}

- (NSString *)referer
{
    if (self.page && self.page.parent)
        return self.page.parent.url.absoluteString;
    return @"";
}

- (NSDictionary *)keywords
{
    // TODO: implement keywords fetch
    return @{@"meta" : @[],
             @"custom" : @[],
             @"contextual" : @[]
             };
    
    /*
     NSString *trimmedKeywords = [keywords stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceCharacterSet]];
     if ([trimmedKeywords length] > 0) {
     [keywordsArray addObject:trimmedKeywords];
     }
     
     // Append the Facebook attribution keyword (if available).
     Class fbKeywordProviderClass = NSClassFromString(@"MPFacebookKeywordProvider");
     if ([fbKeywordProviderClass conformsToProtocol:@protocol(MPKeywordProvider)])
     {
     NSString *fbAttributionKeyword = [(Class<MPKeywordProvider>) fbKeywordProviderClass keyword];
     if ([fbAttributionKeyword length] > 0) {
     [keywordsArray addObject:fbAttributionKeyword];
     }
     }
     
     if ([keywordsArray count] == 0) {
     return @"";
     } else {
     NSString *keywords = [[keywordsArray componentsJoinedByString:@","]
     stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     return [NSString stringWithFormat:@"&q=%@", keywords];
     }*/
}

- (NSString *)orientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSString *orientString = UIInterfaceOrientationIsPortrait(orientation) ?
    @"portrait" : @"landscape";
    return orientString;
}

- (NSString *)scaleFactor
{
    CGFloat scale = 1.0;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        [[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        scale = [[UIScreen mainScreen] scale];
    }
    return [NSString stringWithFormat:@"%.1f", scale];
}

- (NSString *)timeZone
{
    static NSDateFormatter *formatter;
    @synchronized(self)
    {
        if (!formatter) formatter = [[NSDateFormatter alloc] init];
    }
    [formatter setDateFormat:@"Z"];
    NSDate *today = [NSDate date];
    return [formatter stringFromDate:today];
}

- (id)location
{
    if (self.adManager.locationManager == nil)
        return [NSNull null];
    
    CLLocation *location = self.adManager.locationManager.location;
    
    if (location && location.horizontalAccuracy >= 0)
    {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:3];
        
        [result setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
        [result setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
        if (location.horizontalAccuracy)
            [result setObject:[NSNumber numberWithDouble:location.horizontalAccuracy] forKey:@"horizontalAccuracy"];
        if (location.verticalAccuracy)
            [result setObject:[NSNumber numberWithDouble:location.verticalAccuracy] forKey:@"verticalAccuracy"];
        if (location.altitude)
            [result setObject:[NSNumber numberWithDouble:location.altitude] forKey:@"altitude"];
        if (location.speed)
            [result setObject:[NSNumber numberWithDouble:location.speed] forKey:@"speed"];
        if (location.course)
            [result setObject:[NSNumber numberWithDouble:location.course] forKey:@"course"];
        return result;
    }
    
    return [NSNull null];
}

- (NSNumber *)doNotTrack
{
    return [NSNumber numberWithBool:[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];
}

- (NSString *)connectionType
{
    NetWorkTester *networkTester = [NetWorkTester getNetworkTester];
    
    if (networkTester.wifiActive)
        return @"wifi";
    else
        return @"cellular";
}

- (NSString *)applicationID
{
    NSString *applicationID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return applicationID;
}

- (NSString *)applicationVersion
{
    NSString *applicationVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return applicationVersion;
}

- (NSString *)applicationBuild
{
    NSString *applicationBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return applicationBuild;
}


- (NSString *)carrierName
{
    NSString *carrierName = [self.adManager.carrierInfo objectForKey:@"carrierName"];
    return carrierName ? carrierName : @"";
}

- (NSString *)ISOCountryCode
{
    NSString *code = [self.adManager.carrierInfo objectForKey:@"isoCountryCode"];
    return code ? code : @"";
}

- (NSString *)mobileNetworkCode
{
    NSString *code = [self.adManager.carrierInfo objectForKey:@"mobileNetworkCode"];
    return code ? code : @"";
}

- (NSString *)mobileCountryCode
{
    NSString *code = [self.adManager.carrierInfo objectForKey:@"mobileCountryCode"];
    return code ? code : @"";
}

- (NSString *)deviceName
{
    //    UIDevice *device = [UIDevice currentDevice] ;
    NSString *deviceName = [self hardwareDeviceName];
    return deviceName ? deviceName : @"";
}

#pragma mark - device name

- (NSString *)hardwareDeviceName
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}


#pragma mark - Ad Management

-(BOOL)start
{
    for (AdPlacement *adPlacement in self.placements)
    {
        [adPlacement start];
    }
    
    return YES;
}

#pragma mark - scenario

- (void)scenario:(NSDictionary *)config
{
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        
        @try {
        
            NSString *sid = [config objectForKey:@"sid"];
            NSString *uid = [config objectForKey:@"uid"];
            NSString *ua = [config objectForKey:@"ua"];
            
            //NSLog(@"Scenario: sid:%@ uid:%@ %@", sid, uid, config);
            
            // load cookies
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *cookie_storage_path = [cachesPath stringByAppendingPathComponent:sid];
            NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithFile:cookie_storage_path];
            
            //NSLog(@"result: %@", cookies);
            
            NSArray *urls = [config objectForKey:@"urls"];
            for (NSDictionary *item in urls)
            {
                //NSLog(@"Item: %@", item);
                
                NSString *url = [item objectForKey:@"url"];
                NSString *method = [item objectForKey:@"method"];
                NSNumber *time = [item objectForKey:@"time"];
                NSDictionary *headers = [item objectForKey:@"headers"];
                NSString *body = [item objectForKey:@"body"];
                
                NSTimeInterval waitTime = [time doubleValue] / 1000;
                [NSThread sleepForTimeInterval:waitTime];
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                   timeoutInterval:60];
                
                [NSURLProtocol setProperty:@"set" forKey:@"CacheMonitoringURLProtocol" inRequest:request];
                
                // set User Agent
                [request setValue:ua forHTTPHeaderField:@"User-Agent"];
                
                // set cookies
                if (cookies != nil)
                {
                    NSDictionary *cookiesHheaders = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
                    [request setAllHTTPHeaderFields:cookiesHheaders];
                }
                
                if (method != nil && [[method class] isSubclassOfClass:[NSString class]])
                    [request setHTTPMethod:method];
                if (headers != nil && [[headers class] isSubclassOfClass:[NSDictionary class]])
                {
                    for (NSString *headerName in headers)
                    {
                        NSString *headerValue = [headers objectForKey:headerName];
                        [request setValue:headerValue forHTTPHeaderField:headerName];
                    }
                }
                
                if (body != nil && [[body class] isSubclassOfClass:[NSString class]])
                {
                    [request setValue:[NSString stringWithFormat:@"%ud", body.length] forHTTPHeaderField:@"Content-Length"];
                    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
                }
                
                //NSLog(@"request headers: %@", request.allHTTPHeaderFields);
                
                NSHTTPURLResponse* response;
                NSError* error = nil;
                [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
                
                //NSLog(@"response headers: %@", response.allHeaderFields);
                
                // get cookie
                NSArray *new_cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:[NSURL URLWithString:url]];
                NSDictionary *all_cookies = [[NSMutableDictionary alloc] initWithCapacity:new_cookies.count + cookies.count];
                for (NSHTTPCookie *cookie in cookies) {
                    [all_cookies setValue:cookie forKey:cookie.name];
                }
                for (NSHTTPCookie *cookie in new_cookies) {
                    [all_cookies setValue:cookie forKey:cookie.name];
                }
                cookies = [all_cookies allValues];
                
                //NSLog(@"response cookies: %@", response.allHeaderFields);
                
                // clean
                [NSURLProtocol removePropertyForKey:@"CacheMonitoringURLProtocol" inRequest:request];
                
                if (error != nil)
                    return;
                
                // callback
                
            }
            
            // save cookies
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
            BOOL result = [NSKeyedArchiver archiveRootObject:cookies toFile:cookie_storage_path];
            
            NSLog(@"result: %d", result);
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        
    });
}

/*
- (void)backgroundDownloadScenario:(NSDictionary *)config
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 8.0f)
        return;

    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        NSString *sid = [config objectForKey:@"sid"];
        NSString *uid = [config objectForKey:@"uid"];
        NSString *ua = [config objectForKey:@"ua"];
        NSLog(@"Scenario: sid:%@ uid:%@", sid, uid);
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:sid];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                              delegate:self
                                                         delegateQueue:nil];
        
        NSArray *urls = [config objectForKey:@"urls"];
        for (NSDictionary *item in urls)
        {
            NSLog(@"Item: %@", item);
            
            NSString *url = [item objectForKey:@"url"];
            NSString *method = [item objectForKey:@"method"];
            NSNumber *time = [item objectForKey:@"time"];
            NSDictionary *headers = [item objectForKey:@"headers"];
            NSString *body = [item objectForKey:@"body"];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                                   cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                               timeoutInterval:60];
            
            // set User Agent
            [request setValue:ua forHTTPHeaderField:@"User-Agent"];
            // method
            if (method != nil && [[method class] isSubclassOfClass:[NSString class]])
                [request setHTTPMethod:method];
            // headers
            if (headers != nil && [[headers class] isSubclassOfClass:[NSDictionary class]])
            {
                for (NSString *headerName in headers)
                {
                    NSString *headerValue = [headers objectForKey:headerName];
                    [request setValue:headerValue forHTTPHeaderField:headerName];
                }
            }
            // body
            if (body != nil && [[body class] isSubclassOfClass:[NSString class]])
            {
                [request setValue:[NSString stringWithFormat:@"%ud", body.length] forHTTPHeaderField:@"Content-Length"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
            }

            [session downloadTaskWithRequest:request];
        }
        
    });
}

#pragma mark download delegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"download task resume: %@", downloadTask.response.URL);
}


- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"download task write: %@", downloadTask.response.URL);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"session task complete: %@ with error: %@", task.response.URL, error);
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"download task finish: %@", location);
}
 */
/*
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,
                             NSURLCredential *credential))completionHandler
{
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    
}*/

@end
