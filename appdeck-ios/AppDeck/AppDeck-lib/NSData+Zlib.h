//
//  NSData+Zlib.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/12/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Zlib)

- (NSData *)gzipInflate;
- (NSData *)gzipDeflate;

@end
