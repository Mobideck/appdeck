//
//  NetAvenirAdViewController.h
//  Oxom
//
//  Created by Sébastien Sans on 13/10/2015.
//  Copyright (c) 2015 Sébastien Sans. All rights reserved.
//

#import "../../AppDeckAdViewController.h"
#import "NetAvenirAdEngine.h"
#import <CoreLocation/CoreLocation.h>

@interface NetAvenirAdViewController : AppDeckAdViewController <NAAdPlacementDelegate>

- (id)initWithAdRation:(AdRation *)adRation engine:(NetAvenirAdEngine *)adEngine config:(NSDictionary *)config;

@property (nonatomic, strong)   NetAvenirAdEngine *adEngine;
@property (strong, nonatomic) NSString *zid;

@end
