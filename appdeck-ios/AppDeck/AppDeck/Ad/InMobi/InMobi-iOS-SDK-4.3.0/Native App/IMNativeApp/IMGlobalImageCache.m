//
//  IMGlobalImageCache.m
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import "IMGlobalImageCache.h"

static IMGlobalImageCache* cache;

@interface IMGlobalImageCache()

@property (nonatomic, strong) NSMutableDictionary* globalImageChache;

@end

@implementation IMGlobalImageCache


+(IMGlobalImageCache*)sharedCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[IMGlobalImageCache alloc] init];
    });
    return cache;
}

-(id)init {
    if (self = [super init]) {
        self.globalImageChache = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)addImage:(UIImage*)image forKey:(NSString*)key {
    if (image == nil || key == nil) {
        return;
    }
    @synchronized([IMGlobalImageCache class]) {
        [self.globalImageChache setValue:image forKey:key];
    }
}

-(void)removeImageForKey:(NSString*)key {
    if (key == nil) {
        return;
    }
    @synchronized([IMGlobalImageCache class]) {
        [self.globalImageChache removeObjectForKey:key];
    }
}

-(UIImage*)imageForKey:(NSString*)key {
    if (key == nil) {
        return nil;
    }
    
    return [self.globalImageChache objectForKey:key];
}


@end
