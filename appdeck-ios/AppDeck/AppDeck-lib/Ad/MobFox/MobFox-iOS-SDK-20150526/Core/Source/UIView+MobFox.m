//
//  UIView+MobFox.m
//  MobFoxDemo
//
//  Created by Michał Kapuściński on 23.05.2014.
//

#import "UIView+MobFox.h"
#import <objc/runtime.h>

static char const * const TextAssetKey = "MobFoxTextAssetKey";
static char const * const ImageAssetKey = "MobFoxImageAssetKey";

@implementation UIView (MobFox)

@dynamic MobFoxTextAsset;
@dynamic MobFoxImageAsset;

- (id)MobFoxTextAsset {
    return objc_getAssociatedObject(self, TextAssetKey);
}

- (void)setMobFoxTextAsset:(NSString*)asset {
    objc_setAssociatedObject(self, TextAssetKey, asset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)MobFoxImageAsset {
    return objc_getAssociatedObject(self, ImageAssetKey);
}

- (void)setMobFoxImageAsset:(NSString*)asset {
    objc_setAssociatedObject(self, ImageAssetKey, asset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
