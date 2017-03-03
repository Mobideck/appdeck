//
//  MPGlobalSpecHelper.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPGlobalSpecHelper : NSObject

+ (CGSize)screenResolution;
+ (CGRect)screenBounds;
+ (CGFloat)deviceScaleFactor;
+ (NSDictionary *)dictionaryFromQueryString:(NSString *)query;
+ (NSArray *)convertStrArrayToURLArray:(NSArray *)strArray;

@end
