//
//  NSString+URLEncoding.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 15/12/12.
//  Copyright (c) 2012 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
-(NSString *)urlDecodeUsingEncoding:(NSStringEncoding)encoding;

@end
