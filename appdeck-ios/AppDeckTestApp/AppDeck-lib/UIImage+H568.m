//
//  UIImage+H568.m
//
//  Created by Angel Garcia on 9/28/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "UIImage+H568.h"
//#import "NSObjCRuntime.h"

@implementation UIImage (H568)

typedef struct objc_method *Method;
Method class_getClassMethod(Class aClass, SEL aSelector);
void method_exchangeImplementations(Method m1, Method m2);

+ (void)load {
    if  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
        ([UIScreen mainScreen].bounds.size.height > 480.0f)) {
        method_exchangeImplementations(class_getClassMethod(self, @selector(imageNamed:)),
                                       class_getClassMethod(self, @selector(imageNamedH568:)));
    }
}

+ (UIImage *)imageNamedH568:(NSString *)imageName {

    NSMutableString *imageNameMutable = [imageName mutableCopy];

    //Delete png extension
    NSRange extension = [imageName rangeOfString:@".png" options:NSBackwardsSearch | NSAnchoredSearch];
    if (extension.location != NSNotFound) {
        [imageNameMutable deleteCharactersInRange:extension];
    }

    //Look for @2x to introduce -568h string
    NSRange retinaAtSymbol = [imageName rangeOfString:@"@2x"];
    if (retinaAtSymbol.location != NSNotFound) {
        [imageNameMutable insertString:@"-568h" atIndex:retinaAtSymbol.location];
    } else {
        [imageNameMutable appendString:@"-568h@2x"];
    }
    
    //Check if the image exists and load the new 568 if so or the original name if not
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:@"png"];
    if (imagePath) {
        //Remove the @2x to load with the correct scale 2.0
        [imageNameMutable replaceOccurrencesOfString:@"@2x" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, [imageNameMutable length])];
        return [UIImage imageNamedH568:imageNameMutable];
    } else {
        return [UIImage imageNamedH568:imageName];
    }
}

@end
