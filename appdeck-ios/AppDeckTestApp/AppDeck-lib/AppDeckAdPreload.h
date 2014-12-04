//
//  AppDeckAdPreload.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 11/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDeckAdConfig;
@class AppDeckAdUsage;
@class AppDeckAdViewController;

@interface AppDeckAdPreload : NSObject

@property (strong, nonatomic)    NSString*   adType;

@property (strong, nonatomic)    AppDeckAdConfig*   adConfig;

@property (strong, nonatomic)    AppDeckAdUsage*    adUsage;

@property (strong, nonatomic)    NSMutableArray*    AdEngineChain;

@property (strong, nonatomic)    AppDeckAdViewController       *workingAd;

@property (strong, nonatomic)    AppDeckAdViewController  *readyAd;

@property (assign, nonatomic)    int originEvent;

@end
