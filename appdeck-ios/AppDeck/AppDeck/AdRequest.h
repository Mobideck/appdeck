//
//  AdRequest.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/08/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AdManager.h"
#import "JSonHTTPApi.h"

@interface AdRequest : NSObject
{
    JSonHTTPApi     *api;
    
}

@property (nonatomic, weak) AdManager           *adManager;
@property (nonatomic, weak) PageViewController  *page;

// request informations
@property (nonatomic, assign) BOOL          success;
@property (nonatomic, strong) NSString      *pageViewId;
@property (nonatomic, strong) NSDate        *serverRequestDate;
@property (nonatomic, strong) NSString      *templateId;
@property (nonatomic, strong) NSDictionary  *config;

@property (nonatomic, strong) NSMutableArray       *placements;


-(id)initWithManager:(AdManager *)adManager page:(PageViewController *)page;

-(void)cancel;

@end
