//
//  NSError+errorWithFormat.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "NSError+errorWithFormat.h"

@implementation NSError (errorWithFormat)

+(NSError *)errorWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:reason forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"appError" code:100 userInfo:errorDetail];
}

@end
