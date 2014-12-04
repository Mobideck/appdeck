//
//  AdScenario.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 04/09/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdManager.h"
#import "AdPlacement.h"

@class AdRation;

@interface AdScenario : NSObject
{
    NSTimer *timer;
    
    // adRation that we are working with right now
    // state: new => init => (failed, ok, next)
    // failed: we remove it and try next one
    // ok: we stop search for rations
    // next: we store this ration in backgroundRations and try next one
    AdRation *currentAdRation;
    
    // ads that are curently running
    NSMutableArray *backgroundAdRations;
    
    BOOL noMoreRation;
    
    int nextRationIdx;
}

@property (nonatomic, weak) AdPlacement *adPlacement;
@property (nonatomic, strong) NSDictionary    *config;
@property (nonatomic, strong) NSDictionary    *rules;

@property (nonatomic, assign)   float   ruleMaxWidth;
@property (nonatomic, assign)   float   ruleMaxHeight;

@property (nonatomic, strong) NSMutableArray *rations;


-(id)initWithPlacement:(AdPlacement *)adPlacement config:(NSDictionary *)config;

-(void)cancel;

-(BOOL)isValid;
-(BOOL)start;

@end
