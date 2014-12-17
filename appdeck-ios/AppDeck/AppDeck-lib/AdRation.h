//
//  AdRation.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 01/09/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdScenario.h"

typedef enum {
    AdRationStateNotSet = 0,
    AdRationStateNew,
    AdRationStateWorking,
    AdRationStateOk,
    AdRationStateFailed,
    AdRationStateNext
} AdRationState;

@interface AdRation : NSObject
{
    NSTimer *timer;
}

@property (nonatomic, weak)     AppDeckAdEngine *adEngine;
@property (nonatomic, strong)   AppDeckAdViewController *adViewController;

@property (nonatomic, weak) AdManager       *adManager;
@property (nonatomic, weak) AdRequest       *adRequest;
@property (nonatomic, weak) AdScenario      *adScenario;

@property (nonatomic, strong) NSDictionary  *config;

@property (nonatomic, strong) NSString      *rationId;
@property (nonatomic, strong) NSString      *rationType;

// format
@property (nonatomic, strong) NSString      *formatId;
@property (nonatomic, assign) float         formatWidth;
@property (nonatomic, assign) float         formatHeight;
@property (nonatomic, strong) NSString      *formatType;

// settings
@property (nonatomic, strong) NSDictionary  *settings;

// offer
@property (nonatomic, strong) NSString      *offerId;
@property (nonatomic, strong) NSString      *offerType;
@property (nonatomic, strong) NSDictionary  *offerSettings;

@property (nonatomic, assign) AdRationState state;

//@property (nonatomic, strong) NSMutableArray *adsConfig;

-(id)initWithScenario:(AdScenario *)adScenario config:(NSDictionary *)config;

-(BOOL)start;

-(void)cancel;

@end
