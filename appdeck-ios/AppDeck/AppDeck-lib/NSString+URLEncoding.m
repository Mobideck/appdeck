//
//  NSString+URLEncoding.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 15/12/12.
//  Copyright (c) 2012 Mathieu De Kermadec. All rights reserved.
//

#import "NSString+URLEncoding.h"
#import <CommonCrypto/CommonDigest.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

@implementation NSString (URLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    
    return  [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

//    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
//                                                               (CFStringRef)self,
//                                                               NULL,
//                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
//                                                               CFStringConvertNSStringEncodingToEncoding(encoding));
}

-(NSString *)urlDecodeUsingEncoding:(NSStringEncoding)encoding;
{
   // return [[self stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:encoding];
     return [[self stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByRemovingPercentEncoding];
}
@end
