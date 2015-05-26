//
//  MPSessionTracker.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSessionTrackerMF.h"
#import "MPConstantsMF.h"
#import "MPIdentityProviderMF.h"
#import "MPGlobalMF.h"
#import "MPCoreInstanceProviderMF.h"

@implementation MPSessionTrackerMF

+ (void)load
{
    if (SESSION_TRACKING_ENABLED) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trackEvent)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trackEvent)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
}

+ (void)trackEvent
{
    [NSURLConnection connectionWithRequest:[[MPCoreInstanceProviderMF sharedProvider] buildConfiguredURLRequestWithURL:[self URL]]
                                  delegate:nil];
}

+ (NSURL *)URL
{
    NSString *path = [NSString stringWithFormat:@"http://%@/m/open?v=%@&udid=%@&id=%@&av=%@&st=1",
                      HOSTNAME,
                      MP_SERVER_VERSION,
                      [MPIdentityProviderMF identifier],
                      [[[NSBundle mainBundle] bundleIdentifier] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                      ];

    return [NSURL URLWithString:path];
}

@end
