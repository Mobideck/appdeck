//
//  MMediaAdEngine.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeckAdEngine.h"
#import <CoreLocation/CoreLocation.h>

@class MMRequest;

@interface MMediaAdEngine : AppDeckAdEngine

@property (strong, nonatomic) NSString *bannerAPID;
@property (strong, nonatomic) NSString *rectangleAPID;
@property (strong, nonatomic) NSString *InterstitialAPID;

-(void)passMetadata:(MMRequest *)request;

@end
