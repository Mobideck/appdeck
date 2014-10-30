//
//  NSDictionary+query.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 15/12/12.
//  Copyright (c) 2012 Mathieu De Kermadec. All rights reserved.
//

#import "NSDictionary+query.h"

@implementation NSDictionary (query)

-(id)query:(NSString *)query
{
    NSArray *chunks = [query componentsSeparatedByString:@"."];
    NSDictionary *target = self;
    for (NSString *chunk in chunks)
    {
        NSDictionary *new_target = [target objectForKey:chunk];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            NSDictionary *new_target_tablet = [target objectForKey:[chunk stringByAppendingString:@"_tablet"]];
            if (new_target_tablet)
                new_target = new_target_tablet;
        }

        target = new_target;
        
        if (target == nil)
            return nil;
    }
    return target;
}

-(id)query:(NSString *)query defaultValue:(id)value
{
    id ret = [self query:query];
    if (ret != nil)
        return ret;
    return value;
}

@end
