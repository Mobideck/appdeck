//
//  NetAvenirAdEngine.h
//  Oxom
//
//  Created by Sébastien Sans on 13/10/2015.
//  Copyright (c) 2015 Sébastien Sans. All rights reserved.
//

#import "AppDeckAdEngine.h"
#import <CoreLocation/CoreLocation.h>
#import "NetAvenirAds.h"

@interface NetAvenirAdEngine : AppDeckAdEngine

@property (strong, nonatomic) NSString *zid;

@end
