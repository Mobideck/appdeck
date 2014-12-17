//
//  NSDictionary+query.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 15/12/12.
//  Copyright (c) 2012 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (query)

-(id)query:(NSString *)query;
-(id)query:(NSString *)query defaultValue:(id)value;

@end
