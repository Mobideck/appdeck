//
//  MPAdSection.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPAdInfo;

@interface MPAdSection : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign, readonly) NSUInteger count;

+ (NSArray *)adSections;
+ (MPAdSection *)sectionWithTitle:(NSString *)title ads:(NSArray *)ads;

- (MPAdInfo *)adAtIndex:(NSUInteger)index;

@end
