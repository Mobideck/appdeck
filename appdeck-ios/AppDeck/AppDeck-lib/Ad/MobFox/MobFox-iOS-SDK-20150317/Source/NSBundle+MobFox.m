#import "NSBundle+MobFox.h"

@implementation NSBundle (MobFox)

+ (NSBundle*)mobFoxLibraryResourcesBundle {

    static dispatch_once_t onceToken;
    static NSBundle *mobFoxLibraryResourcesBundle = nil;

    dispatch_once(&onceToken, ^{
        mobFoxLibraryResourcesBundle = [NSBundle bundleWithIdentifier:@"com.mobfox.MobFox"];
    });

    return mobFoxLibraryResourcesBundle;
}
@end
