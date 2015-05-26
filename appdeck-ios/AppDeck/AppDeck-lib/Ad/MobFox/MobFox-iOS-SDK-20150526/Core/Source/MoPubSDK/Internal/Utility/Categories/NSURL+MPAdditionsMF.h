//
//  NSURL+MPAdditionsMF.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (MPAdditionsMF)

- (NSDictionary *)mp_queryAsDictionary;
- (BOOL)mp_hasTelephoneScheme;
- (BOOL)mp_hasTelephonePromptScheme;

@end
