//
//  ScreenConfiguration.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "ScreenConfiguration.h"
#import "RE2Regexp.h"
#import "NSDictionary+query.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"

@implementation ScreenConfiguration

+(ScreenConfiguration *)defaultConfigurationWitehLoader:(LoaderViewController *)loader
{
    ScreenConfiguration *defaultConfiguration = [[ScreenConfiguration alloc] init];
    defaultConfiguration.title = nil;
    defaultConfiguration.urlRegex = nil;
    defaultConfiguration.notUrlRegex = nil;
    defaultConfiguration.type = nil;
    defaultConfiguration.isPopUp = false;
    defaultConfiguration.enableShare = false;
    defaultConfiguration.ttl = 600;
    defaultConfiguration.logo = nil;
    defaultConfiguration.loader = loader;
    return defaultConfiguration;
}

-(id)initWithConfiguration:(NSDictionary *)configuration loader:(LoaderViewController *)loader
{
    self = [super init];
    
    if (self)
    {
        self.loader = loader;
        self.title = [configuration query:@"title" defaultValue:nil];
        self.type = [configuration query:@"type" defaultValue:nil];
        self.logo = [configuration query:@"logo" defaultValue:nil];
        // todo: check nsnull value
        self.urlRegex = [[NSMutableArray alloc] init];
        self.urlRegexStrings = [configuration query:@"urls" defaultValue:nil];
        self.notUrlRegex = [[NSMutableArray alloc] init];
        self.notUrlRegexStrings = [configuration query:@"not_urls" defaultValue:nil];
        id isPopUp = [configuration query:@"popup" defaultValue:nil];
        if (isPopUp != nil)
        {
            self.isPopUp = [isPopUp boolValue];
        }
        self.enableShare = [[configuration query:@"enable_share" defaultValue:nil] boolValue]; //[configuration[@"enable_share"] boolValue];
        self.ttl = 600;
        
        if ([configuration query:@"ttl"] != nil)
            //    if (configuration[@"ttl"] != nil)
            self.ttl = [[configuration query:@"ttl"] intValue];
        
        for (NSString *regexStringRaw in self.urlRegexStrings)
        {
            NSString *regexString = [regexStringRaw stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (regexString.length == 0)
                continue;
            RE2Regexp *regex = [[RE2Regexp alloc] initWithString:regexString];
            if (regex == nil)
            {
                NSLog(@"invalid Rexep URL : %@", regexString);
                continue;
            }
            [self.urlRegex addObject:regex];
        }
        for (NSString *regexStringRaw in self.notUrlRegexStrings)
        {
            NSString *regexString = [regexStringRaw stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (regexString.length == 0)
                continue;
            RE2Regexp *regex = [[RE2Regexp alloc] initWithString:regexString];
            if (regex == nil)
            {
                NSLog(@"invalid Rexep URL : %@", regexString);
                continue;
            }
            [self.notUrlRegex addObject:regex];
        }
    }
    return self;
}

-(BOOL)isRelated:(NSURL *)url
{
    const char *absoluteURL = [url.absoluteString UTF8String];
    const char *relativeURL = [[url.absoluteString substringFromIndex:(url.scheme.length + 3 + url.host.length)] UTF8String];

    for (RE2Regexp *regex in self.notUrlRegex) {
        if ([regex match:absoluteURL])
            return NO;
        if ([url.host isEqualToString:self.loader.conf.baseUrl.host] && [regex match:relativeURL])
            return NO;
    }
    for (RE2Regexp *regex in self.urlRegex) {
        if ([regex match:absoluteURL])
            return YES;
        if ([url.host isEqualToString:self.loader.conf.baseUrl.host] && [regex match:relativeURL])
            return YES;
    }
    return NO;
}

-(BOOL)matchThisConfiguration:(NSURL *)url
{
    if (self.urlRegex != nil)
        return [self isRelated:url];
    return YES;
}


@end
