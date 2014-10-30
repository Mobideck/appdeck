//
//  AppDeckADConfig.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 10/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDeckAdConfig : NSObject

+(AppDeckAdConfig *)adConfigFronJson:(NSDictionary *)config;

@property (nonatomic, strong) NSString   *adType;

@property (nonatomic, assign) int   priority;
@property (nonatomic, assign) int   weight;

@property (nonatomic, assign) CGFloat   eCPM;

@property (nonatomic, assign) int   refreshTime; // auto refresh after XX seconds

@property (nonatomic, assign) int   percentPrint; // allow some random print. 100% = always 50 = half time, 0% = never ...

@property (nonatomic, assign) int   eventCap; // show only every XX enabled event
@property (nonatomic, assign) int   pageCap; // show only every XX page view (launch, root, push, pop, swipe, popup ...)
@property (nonatomic, assign) int   timeCap; // show only every XX seconds
@property (nonatomic, assign) int   timeErrorCap; // on error retry every XX seconds
@property (nonatomic, assign) int   sessionCap; // show only every XX session (user must close app, or put in in background)
@property (nonatomic, assign) int   userCap; // 0 = disabled, 1 = show only once per user, 2 = non sense ...

@property (nonatomic, assign) BOOL   showOnEventLaunch;
@property (nonatomic, assign) BOOL   showOnEventRoot;
@property (nonatomic, assign) BOOL   showOnEventPush;
@property (nonatomic, assign) BOOL   showOnEventPop;
@property (nonatomic, assign) BOOL   showOnEventSwipe;
@property (nonatomic, assign) BOOL   showOnEventPopUp;

- (NSComparisonResult)compare:(AppDeckAdConfig *)otherAdConfig;

@end
