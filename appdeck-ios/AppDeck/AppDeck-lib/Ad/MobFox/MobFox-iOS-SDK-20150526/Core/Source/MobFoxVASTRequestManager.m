//
//  MobFoxVASTRequest.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 18.05.2015.
//
//

#import "MobFoxVASTRequestManager.h"
#import <AdSupport/AdSupport.h>
#import "NSString+MobFox.h"

static NSString * const SERVER_URL = @"http://my.mobfox.com/request.php";
static NSString * const MobFoxVASTRequestlErrorDomain = @"MobFoxVASTRequest";

@interface MobFoxVASTRequestManager () {
}

@property (nonatomic, assign) CGFloat currentLatitude;
@property (nonatomic, assign) CGFloat currentLongitude;
@property (nonatomic, strong) NSString *userAgent;

@end

@implementation MobFoxVASTRequestManager

-(instancetype)init {
    self = [super init];
    if (self) {
        UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        self.userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }
    return self;
}

- (void)requestVAST {
    if (!self.delegate) {
        NSLog(@"delegate for VAST request not set! Cannot perform request.");
    }
    
    NSString* publisherId = [self.delegate publisherIdForMobFoxVASTRequest];
    [self performSelectorInBackground:@selector(asyncRequestVASTWithPublisherId:) withObject:publisherId];
}


- (void)asyncRequestVASTWithPublisherId:(NSString *)publisherId
{
    @autoreleasepool
    {
        NSString *mRaidCapable;
        if(self.mraidSupported) {
            mRaidCapable = @"1";
        } else {
            mRaidCapable = @"0";
        }
        
        NSString *adWidth = @"320";
        NSString *adHeight = @"480";
        NSString *adStrict = @"0";
        
        int r = arc4random_uniform(50000);
        NSString *random = [NSString stringWithFormat:@"%d", r];
        
        NSString *requestType;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            requestType = @"iphone_app";
        }
        else
        {
            requestType = @"ipad_app";
        }
        
        NSString *osVersion = [UIDevice currentDevice].systemVersion;
        
        NSString *requestString;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
        NSString *iosadvid;
        if ([ASIdentifierManager instancesRespondToSelector:@selector(advertisingIdentifier )]) {
            iosadvid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            NSString *o_iosadvidlimit = @"0";
            if (NSClassFromString(@"ASIdentifierManager")) {
                
                if (![ASIdentifierManager sharedManager].advertisingTrackingEnabled) {
                    o_iosadvidlimit = @"1";
                }
            }
            
            requestString=[NSString stringWithFormat:@"c_mraid=%@&c_customevents=1&r_type=video&r_resp=vast20&o_iosadvidlimit=%@&rt=%@&u=%@&u_wv=%@&u_br=%@&o_iosadvid=%@&v=%@&s=%@&iphone_osversion=%@&r_random=%@",
                           [mRaidCapable stringByUrlEncoding],
                           [o_iosadvidlimit stringByUrlEncoding],
                           [requestType stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [iosadvid stringByUrlEncoding],
                           [SDK_VERSION stringByUrlEncoding],
                           [publisherId stringByUrlEncoding],
                           [osVersion stringByUrlEncoding],
                           [random stringByUrlEncoding]];
            
        } else {
            requestString=[NSString stringWithFormat:@"c_mraid=%@&c_customevents=1&r_type=video&r_resp=vast20&rt=%@&u=%@&u_wv=%@&u_br=%@&v=%@&s=%@&iphone_osversion=%@&r_random=%@",
                           [mRaidCapable stringByUrlEncoding],
                           [requestType stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [SDK_VERSION stringByUrlEncoding],
                           [publisherId stringByUrlEncoding],
                           [osVersion stringByUrlEncoding],
                           [random stringByUrlEncoding]];
            
        }
#else
        
        requestString=[NSString stringWithFormat:@"c_mraid=%@&c_customevents=1&r_type=video&r_resp=vast20&rt=%@&u=%@&u_wv=%@&u_br=%@&v=%@&s=%@&iphone_osversion=%@&r_random=%@",
                       [mRaidCapable stringByUrlEncoding],
                       [requestType stringByUrlEncoding],
                       [self.userAgent stringByUrlEncoding],
                       [self.userAgent stringByUrlEncoding],
                       [[self browserAgentString] stringByUrlEncoding],
                       [SDK_VERSION stringByUrlEncoding],
                       [publisherId stringByUrlEncoding],
                       [osVersion stringByUrlEncoding],
                       [random stringByUrlEncoding]];
        
#endif
        NSString *requestStringWithLocation;
        if(self.locationAwareAdverts && self.currentLatitude && self.currentLongitude)
        {
            NSString *latitudeString = [NSString stringWithFormat:@"%+.6f", self.currentLatitude];
            NSString *longitudeString = [NSString stringWithFormat:@"%+.6f", self.currentLongitude];
            
            requestStringWithLocation = [NSString stringWithFormat:@"%@&latitude=%@&longitude=%@",
                                         requestString,
                                         [latitudeString stringByUrlEncoding],
                                         [longitudeString stringByUrlEncoding]
                                         ];
        }
        else
        {
            requestStringWithLocation = requestString;
        }
        
        NSString *fullRequestString;
        
        fullRequestString = [NSString stringWithFormat:@"%@&adspace_width=%@&adspace_height=%@&adspace_strict=%@",
                             requestStringWithLocation,
                             [adWidth stringByUrlEncoding],
                             [adHeight stringByUrlEncoding],
                             [adStrict stringByUrlEncoding]
                             ];
        
        if([self.userGender isEqualToString:@"female"]) {
            fullRequestString = [NSString stringWithFormat:@"%@&demo_gender=f",
                                 fullRequestString];
        } else if([self.userGender isEqualToString:@"male"]) {
            fullRequestString = [NSString stringWithFormat:@"%@&demo_gender=m",
                                 fullRequestString];
        }
        if(self.userAge) {
            NSString *age = [NSString stringWithFormat:@"%d",(int)self.userAge];
            fullRequestString = [NSString stringWithFormat:@"%@&demo_age=%@",
                                 fullRequestString,
                                 [age stringByUrlEncoding]];
        }
        if(self.keywords) {
            NSString *words = [self.keywords componentsJoinedByString:@","];
            fullRequestString = [NSString stringWithFormat:@"%@&demo_keywords=%@",
                                 fullRequestString,
                                 words];
            
        }
        
        if(self.video_min_duration) {
            NSString *minDuration = [NSString stringWithFormat:@"%d",(int)self.video_min_duration];
            fullRequestString = [NSString stringWithFormat:@"%@&v_dur_min=%@",
                                 fullRequestString,
                                 [minDuration stringByUrlEncoding]];
        }
        
        if(self.video_max_duration) {
            NSString *maxDuration = [NSString stringWithFormat:@"%d",(int)self.video_max_duration];
            fullRequestString = [NSString stringWithFormat:@"%@&v_dur_max=%@",
                                 fullRequestString,
                                 [maxDuration stringByUrlEncoding]];
        }
        
        
        NSURL *url;
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", SERVER_URL, fullRequestString]];
        
        
        NSMutableURLRequest *request;
        NSError *error;
        NSURLResponse *response;
        NSData *dataReply;
        
        request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod: @"GET"];
        [request setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
        [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
        
        dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if(error) {
            if ([self.delegate respondsToSelector:@selector(mobfoxVASTRequestDidFailWithError:)])
            {
                [self.delegate mobfoxVASTRequestDidFailWithError:error];
            }
            return;
        }
        
        if(!dataReply) {
            if ([self.delegate respondsToSelector:@selector(mobfoxVASTRequestDidFailWithError:)])
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No response from server" forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:MobFoxVASTRequestlErrorDomain code:0 userInfo:userInfo];
                [self.delegate mobfoxVASTRequestDidFailWithError:error];
            }
            return;
        }
        NSString* replyString = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
        
        if(replyString.length < 1) {
            if ([self.delegate respondsToSelector:@selector(mobfoxVASTRequestDidFailWithError:)])
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Empty response received" forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:MobFoxVASTRequestlErrorDomain code:0 userInfo:userInfo];
                [self.delegate mobfoxVASTRequestDidFailWithError:error];
            }
            return;
        }
        
        [self.delegate mobfoxDidReveiveVASTResponse:replyString];
    }
    
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    self.currentLatitude = latitude;
    self.currentLongitude = longitude;
}

@end
