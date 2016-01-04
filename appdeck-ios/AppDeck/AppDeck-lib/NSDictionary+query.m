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
    id target = self;
    for (NSString *chunk in chunks)
    {
        id new_target = [target objectForKey:chunk];
        
        // ios ?
        {
            id new_new_target = [target objectForKey:[chunk stringByAppendingString:@"_ios"]];
            if (new_new_target != nil)
                new_target = new_new_target;
        }
        
        // tablet ?
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            id new_new_target = [target objectForKey:[chunk stringByAppendingString:@"_tablet"]];
            if (new_new_target != nil)
                new_target = new_new_target;
        } else {
            id new_new_target = [target objectForKey:[chunk stringByAppendingString:@"_phone"]];
            if (new_new_target != nil)
                new_target = new_new_target;
        }
        
        // tablet + ios?
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            id new_new_target = [target objectForKey:[chunk stringByAppendingString:@"_tablet_ios"]];
            if (new_new_target != nil)
                new_target = new_new_target;
        } else {
            id new_new_target = [target objectForKey:[chunk stringByAppendingString:@"_phone_ios"]];
            if (new_new_target != nil)
                new_target = new_new_target;
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
