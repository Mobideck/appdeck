//
//  IMGlobalImageCache.h
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMGlobalImageCache : NSObject

+(IMGlobalImageCache*)sharedCache;

-(void)addImage:(UIImage*)image forKey:(NSString*)key;

-(void)removeImageForKey:(NSString*)key;

-(UIImage*)imageForKey:(NSString*)key;

@end
