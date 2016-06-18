//
//  AppDeckPlugInManager.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/05/2016.
//  Copyright © 2016 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeckPluginManager.h"

@implementation AppDeckPluginManager

+(void)registerAppDeckPlugin:(AppDeckPlugin *)plugin withCommands:(NSArray *)commands;
{
    NSMutableDictionary *plugins = [self getAvailablePlugins];
    for (NSString *command in commands) {
        [plugins setObject:plugin forKey:command];
    }
}

+(NSMutableDictionary *)getAvailablePlugins
{
    static dispatch_once_t once;
    static NSMutableDictionary *plugins;
    dispatch_once(&once, ^{
        plugins = [[NSMutableDictionary alloc] init];
    });
    return plugins;
}

+(BOOL)handleAPICall:(AppDeckApiCall *)call
{
    NSMutableDictionary *plugins = [self getAvailablePlugins];
    AppDeckPlugin *plugin = [plugins objectForKey:call.command];
    if (plugin == nil)
        return NO;
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:",call.command]);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[plugin class] instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:plugin];
    [invocation setArgument:&call atIndex:2];
    [invocation invoke];
    bool returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

@end
