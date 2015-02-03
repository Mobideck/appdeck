//
//  AdRequest.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/08/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import "AdRequest.h"
#import "AdPlacement.h"
#import "JSONKit.h"

#import "LoaderViewController.h"
#import "OpenUDID.h"
#import "SecureUDID.h"
#import "AppDeck.h"
#import "NetWorkTester.h"
#import "JSONKit.h"
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
        //resultJSONData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:&error];
        resultJSONData = [adParams JSONDataWithOptions:JKSerializeOptionPretty|JKSerializeOptionEscapeUnicode error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"JSAPI: Exception while writing JSon: %@: %@", exception, adContext);
        return;
    }
    if (error != nil)
    {
        NSLog(@"JSAPI: Error while writing JSon: %@: %@", error, adContext);
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

@end
