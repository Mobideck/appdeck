//
//  NSString+parseHTTPQuery.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 12/04/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "NSString+parseHTTPQuery.h"
#import "NSString+URLEncoding.h"

@implementation NSString (parseHTTPQuery)

- (NSMutableDictionary *)parseHTTPQuery
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSString *string = self;
    NSRange range = [string rangeOfString:@"?"];
    if (range.length != 0)
        string = [string substringFromIndex:range.location + 1];
    for (NSString *param_str in [string componentsSeparatedByString:@"&"])
    {
        NSArray *param = [param_str componentsSeparatedByString:@"="];
        if ([param count] != 2)
        {
            NSLog(@"warning: can't parse param: '%@' of string '%@', it give %@", param_str, string, param);
        } else {
            [dict setValue:[[param objectAtIndex:1] urlDecodeUsingEncoding:NSUTF8StringEncoding] forKey:[[param objectAtIndex:0] urlDecodeUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    return dict;
}

@end
