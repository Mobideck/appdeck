//
//  NSError+errorWithFormat.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (errorWithFormat)

+(NSError *)errorWithFormat:(NSString *)format, ...;

@end
