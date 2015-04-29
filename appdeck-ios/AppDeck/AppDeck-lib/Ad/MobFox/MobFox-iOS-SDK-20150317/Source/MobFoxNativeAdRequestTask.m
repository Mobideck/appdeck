//
//  MobFoxNativeAdRequestTask.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 17.07.2014.
//
//

#import "MobFoxNativeAdRequestTask.h"
#import "CustomEvent.h"
#import "CustomEventNative.h"


@interface MobFoxNativeAdRequestTask()<CustomEventNativeDelegate> {
    
}
    @property (nonatomic, strong) MobFoxNativeAd* nativeAd;
    @property (nonatomic, strong) CustomEventNative* customEventNative;
    @property (nonatomic, strong) NSDictionary *json;

@end

@implementation MobFoxNativeAdRequestTask

- (void) startRequestWithUrl:(NSURL*)url {
   
    NSMutableURLRequest *request;
    NSError *error;
    NSURLResponse *response;
    NSData *dataReply;
    
    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: @"GET"];
    //        [request setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    NSDictionary *headers;
    
    dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        headers = [(NSHTTPURLResponse *)response allHeaderFields];
    }
    
    if ([dataReply length] == 0) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No inventory for ad request" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:MobFoxNativeAdErrorDomain code:0 userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        return;
    }
    
    if(!dataReply || error){
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No correct response from the server" forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [NSError errorWithDomain:MobFoxNativeAdErrorDomain code:0 userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        return;
    }
    
    NSError *localError = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataReply options:0 error:&localError];
    
    if (localError || !json)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error parsing response from server" forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [NSError errorWithDomain:MobFoxNativeAdErrorDomain code:0 userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        return;
    }
    
    self.json = json;
    [self setupAdWithHeaders:headers];

}



- (void)setupAdWithHeaders:(NSDictionary*)headers
{
    MobFoxNativeAd *ad = [[MobFoxNativeAd alloc]init];
    
    if(headers)
    {
        for(NSString* key in headers) {
            if ([key hasPrefix:@"X-CustomEvent"]) {
                @try {
                    NSString* jsonString = [headers objectForKey:key];
                    NSError *error;
                    NSDictionary *json =
                    [NSJSONSerialization JSONObjectWithData: [jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: &error];
                    if(error) {
                        continue;
                    }
                    CustomEvent *customEvent = [[CustomEvent alloc] init];
                    customEvent.className = [json objectForKey:@"class"];
                    customEvent.optionalParameter = [json objectForKey:@"parameter"];
                    customEvent.pixelUrl = [json objectForKey:@"pixel"];
                    [ad.customEvents addObject:customEvent];
                }
                @catch (NSException *exception) {
                    NSLog(@"Error creating custom event");
                }
    
            }
        }
    }
    
    _nativeAd = ad;
    _customEventNative = nil;
    if([[ad customEvents]count] > 0) {
        [self loadCustomEventNativeAd];
        if(!_customEventNative) {
            [self fillOriginalNativeAdData];
            if([_nativeAd isNativeAdValid]) {
                [self performSelectorOnMainThread:@selector(reportSuccess:) withObject:_nativeAd waitUntilDone:YES];
            } else {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error parsing response from server" forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:MobFoxNativeAdErrorDomain code:0 userInfo:userInfo];
                [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            }
        }
    } else {
        [self fillOriginalNativeAdData];
        if([_nativeAd isNativeAdValid]) {
            [self performSelectorOnMainThread:@selector(reportSuccess:) withObject:_nativeAd waitUntilDone:YES];
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error parsing response from server" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MobFoxNativeAdErrorDomain code:0 userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        }
    }
}

-(void)fillOriginalNativeAdData {

    self.nativeAd.clickUrl = self.json[@"click_url"];
    
    NSDictionary* imageAssets = self.json[@"imageassets"];
    NSEnumerator* imageAssetEnumerator = [imageAssets keyEnumerator];
    NSString* key;
    while (key = [imageAssetEnumerator nextObject]) {
        NSDictionary* assetObject = imageAssets[key];
        NSString* imageUrl = assetObject[@"url"];
        NSString* width =  assetObject[@"width"];
        NSString* height = assetObject[@"height"];
        ImageAsset* asset = [[ImageAsset alloc]initWithUrl:imageUrl width:width height:height];
        [self.nativeAd addImageAsset:asset withType:key];
    }
    
    NSDictionary* textAssets = self.json[@"textassets"];
    NSEnumerator* textAssetEnumerator = [textAssets keyEnumerator];
    while (key = [textAssetEnumerator nextObject]) {
        NSString* text = textAssets[key];
        [self.nativeAd addTextAsset:text withType:key];
    }
    
    NSArray* trackersArray = self.json[@"trackers"];
    for (NSDictionary* trackerObject in trackersArray){
        Tracker* tracker = [[Tracker alloc]init];
        tracker.type = trackerObject[@"type"];
        tracker.url = trackerObject[@"url"];
        [self.nativeAd.trackers addObject:tracker];
    }

}


-(void)loadCustomEventNativeAd {
    _customEventNative = nil;
    while ([_nativeAd.customEvents count] > 0)
    {
        @try
        {
            CustomEvent *event = [_nativeAd.customEvents objectAtIndex:0];
            [_nativeAd.customEvents removeObjectAtIndex:0];
            
            NSString* className = [NSString stringWithFormat:@"%@CustomEventNative",event.className];
            Class customClass = NSClassFromString(className);
            if(customClass) {
                _customEventNative = [[customClass alloc] init];
                _customEventNative.delegate = self;
                [_customEventNative loadNativeAdWithOptionalParameters:event.optionalParameter trackingPixel:event.pixelUrl];
                break;
            } else {
                NSLog(@"custom event native ad for %@ not implemented!",event.className);
            }
        }
        @catch (NSException *exception) {
            _customEventNative = nil;
            NSLog( @"Exception while creating custom event!" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
        
    }
    
}
-(void)dealloc {
    self.delegate = nil;
    self.customEventNative = nil;
    self.nativeAd = nil;
    self.json = nil;
}

#pragma mark custom event native ad delegate:
-(void)customEventNativeFailed {
    [self loadCustomEventNativeAd];
    if(_customEventNative) {
        return;
    }
    [self fillOriginalNativeAdData];
    if([_nativeAd isNativeAdValid]) {
        [self performSelectorOnMainThread:@selector(reportSuccess:) withObject:_nativeAd waitUntilDone:YES];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error parsing response from server" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:MobFoxNativeAdErrorDomain code:0 userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
    }
}

-(void)customEventNativeLoaded:(MobFoxNativeAd *)nativeAd {
    [self performSelectorOnMainThread:@selector(reportSuccess:) withObject:_customEventNative waitUntilDone:YES];
}

- (void)reportError:(NSError *)error
{
    if (self.customEventNative) {
        [self.customEventNative destroy];
    }
	if ([delegate respondsToSelector:@selector(nativeAdFailedToLoadWithError:)])
    {
        [delegate nativeAdFailedToLoadWithError:error];
    }
}

- (void)reportSuccess:(MobFoxNativeAd *)ad
{
    if (self.customEventNative) {
        [self.customEventNative destroy];
    }
	if ([delegate respondsToSelector:@selector(nativeAdDidLoad:)])
	{
		[delegate nativeAdDidLoad:ad];
	}
}

@synthesize userAgent;
@synthesize delegate;



@end
