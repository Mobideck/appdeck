//
//  IMUtilities.h
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define URL_LOADED_NOTIFICATION @"UrlLoaded"

@interface IMUtilities : NSObject

+(NSDictionary*)newsDictFromNativeContent:(NSString*)nativeContent;

+(NSDictionary*)boardDictFromNativeContent:(NSString*)nativeContent;

+(NSArray*)newsItemsFromJsonDict:(NSDictionary*)jsonDict;

+(NSArray*)boardItemsFromJsonDict:(NSDictionary*)jsonDict;

+(NSURL*)getImageURLFromNewsDict:(NSDictionary*)dict;

+(NSURL*)getImageURLFromBoardDict:(NSDictionary*)dict;

@end
