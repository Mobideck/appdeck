//
//  NSString+parseHTTPQuery.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 12/04/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (parseHTTPQuery)

- (NSMutableDictionary *)parseHTTPQuery;

@end
