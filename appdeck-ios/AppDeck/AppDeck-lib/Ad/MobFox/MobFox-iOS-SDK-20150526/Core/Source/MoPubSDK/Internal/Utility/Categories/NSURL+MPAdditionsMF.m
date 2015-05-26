//
//  NSURL+MPAdditions.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "NSURL+MPAdditionsMF.h"

static NSString * const kTelephoneScheme = @"tel";
static NSString * const kTelephonePromptScheme = @"telprompt";

@implementation NSURL (MPAdditionsMF)

- (NSDictionary *)mp_queryAsDictionary
{
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    NSArray *queryElements = [self.query componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        if (keyVal.count >= 2) {
            NSString *key = [keyVal objectAtIndex:0];
            NSString *value = [keyVal objectAtIndex:1];
            [queryDict setObject:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                          forKey:key];
        }
    }
    return queryDict;
}

- (BOOL)mp_hasTelephoneScheme
{
    return [[[self scheme] lowercaseString] isEqualToString:kTelephoneScheme];
}

- (BOOL)mp_hasTelephonePromptScheme
{
    return [[[self scheme] lowercaseString] isEqualToString:kTelephonePromptScheme];
}

@end
