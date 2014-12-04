//
//  CookieStorage.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 11/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CookieStorage : NSObject

+(void)saveCookies;
+(void)loadCookies;

+(void)dumpCookies;

@end
