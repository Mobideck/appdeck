//
//  RE2Regexp.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 29/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RE2Regexp : NSObject

-(id)initWithString:(NSString *)_regexString;
-(BOOL)match:(const char *)text;

@end
