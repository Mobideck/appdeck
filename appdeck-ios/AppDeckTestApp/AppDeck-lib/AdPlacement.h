//
//  AdPlacement.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 01/09/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AdRequest.h"

@class AdScenario;

@interface AdPlacement : NSObject
{

}
@property (nonatomic, weak) AdRequest *adRequest;

@property (nonatomic, strong) NSDictionary    *config;

// placement informations
@property (nonatomic, strong) NSString *placementId;

// settings
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL supportOrientationPortrait;
@property (nonatomic, assign) BOOL supportOrientationLandscape;
@property (nonatomic, strong) NSString    *position;
@property (nonatomic, assign) BOOL sticky;
@property (nonatomic, strong) NSMutableArray *scenarios;

// from all scenarios, we will execute only one, we store it here
@property (nonatomic, strong) AdScenario *adScenario;

-(id)initWithAdrequest:(AdRequest *)adRequest config:(NSDictionary *)config;

-(BOOL)start;

-(void)cancel;

@end
