//
//  MobFoxNativeFormatCreativesManager.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 20.04.2015.
//
//

#import "MobFoxNativeFormatCreativesManager.h"
#import <UIKit/UIKit.h>

static NSString* const BASE_URL = @"http://sdk.starbolt.io/creatives.json";

@interface MobFoxNativeFormatCreativesManager()
    @property (nonatomic, strong) NSMutableArray* creatives;
@end


@implementation MobFoxNativeFormatCreativesManager

static MobFoxNativeFormatCreativesManager* sharedManager = nil;

+(id)sharedManagerWithPublisherId:(NSString*)publisherId {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] initWithPublisherId:publisherId];
    });
    
    return sharedManager;
}

-(instancetype)initWithPublisherId:(NSString*)publisherId {
    self = [super init];
    if (self) {
        self.creatives = [NSMutableArray array];
    }
    [self addBundledCreativeWithName:@"fallback_320x50" width:320 height:50 prob:0];
    [self addBundledCreativeWithName:@"fallback_320x480" width:320 height:480 prob:0];
    
    
    @autoreleasepool {
        UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString* userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];

        [self performSelectorInBackground:@selector(downloadCreatives:) withObject:@[userAgent,publisherId]];
    }
    return self;
}

- (void) downloadCreatives:(NSArray *)array {
    
    NSString* userAgent = array[0];
    NSString* publisherId = array[1];
    
    NSMutableURLRequest *request;
    NSError *error;
    NSURLResponse *response;
    NSData *dataReply;
   
    NSString *requestString = [NSString stringWithFormat:@"%@?p=%@",BASE_URL,publisherId];
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [request setHTTPMethod: @"GET"];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
   
    dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
   
    if(!dataReply || error || [dataReply length] == 0) {
        NSLog(@"Failed to load creatives from server!");
        return;
    }
   
    NSError *localError = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataReply options:0 error:&localError];
    if(localError) {
        NSLog(@"Error parsing cratives JSON: %@", localError.description);
        return;
    }
    if(!json) {
        NSLog(@"Error parsing creatives JSON!");
        return;
    }
    
    NSArray* creatives = json[@"creatives"];
    for (NSDictionary* creativeJson in creatives) {
        MobFoxNativeFormatCreative* creative = [[MobFoxNativeFormatCreative alloc] init];
        creative.name = creativeJson[@"name"];
        creative.templateString = creativeJson[@"template"];
        creative.width = [creativeJson[@"width"] integerValue];
        creative.height = [creativeJson[@"height"] integerValue];
        creative.prob = [creativeJson[@"prob"] doubleValue];
        [self.creatives addObject:creative];
    }
}


- (void) addBundledCreativeWithName:(NSString*)name width:(NSInteger)width height:(NSInteger)height prob:(NSInteger) prob {

    NSString *path = [[NSBundle mainBundle] pathForResource: name ofType: @"mustache"];
    if (!path) {
        NSLog(@"Cannot find resources for creative named: %@",name);
        return;
    }
    
    NSError* error;
    NSString *templateString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if(error) {
        NSLog(@"Cannot load bundled resource, %@",error.description);
        return;
    }
    
    MobFoxNativeFormatCreative* creative = [[MobFoxNativeFormatCreative alloc] init];
    creative.name = name;
    creative.width = width;
    creative.height = height;
    creative.prob = prob;
    creative.templateString = templateString;
    
    [self.creatives addObject:creative];
}


-(MobFoxNativeFormatCreative *)getCreativeWithWidth:(NSInteger)width andHeight:(NSInteger)height {
    
    NSMutableArray* filtered = [NSMutableArray array];
    for (MobFoxNativeFormatCreative* creative in self.creatives) {
        if (creative.width == width && creative.height == height) {
            [filtered addObject:creative];
        }
    }
    
    if ([filtered count] == 0) {
        return nil;
    }
    
    srand48(arc4random());
    double prob = drand48();
    double agg = 0;
    
    for (MobFoxNativeFormatCreative* creative in filtered) {
        if (creative.prob == 0) {
            continue;
        }
        agg += creative.prob;
        if(agg >= prob) {
            return creative;
        }
    }
    
    return [filtered firstObject];
}




@end
