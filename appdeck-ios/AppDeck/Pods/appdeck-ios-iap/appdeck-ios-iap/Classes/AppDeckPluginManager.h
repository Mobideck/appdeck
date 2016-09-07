//
//  AppDeckPlugInManager.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/05/2016.
//  Copyright © 2016 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDeckPlugin.h"

@interface AppDeckPluginManager : NSObject

+(void)registerAppDeckPlugin:(AppDeckPlugin *)plugin withCommands:(NSArray *)commands;

+(NSMutableDictionary *)getAvailablePlugins;

+(BOOL)handleAPICall:(AppDeckApiCall *)call;

@end
