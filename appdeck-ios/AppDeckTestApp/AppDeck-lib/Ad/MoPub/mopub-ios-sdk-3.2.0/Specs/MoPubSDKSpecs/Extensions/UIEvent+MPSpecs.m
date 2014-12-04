//
//  UIEvent+MPSpecs.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UIEvent+MPSpecs.h"

#import <objc/runtime.h>

@interface GSEventProxy : NSObject
{
@public
    unsigned int flags;
    unsigned int type;
    unsigned int ignored1;
    float x1;
    float y1;
    float x2;
    float y2;
    unsigned int ignored2[10];
    unsigned int ignored3[7];
    float sizeX;
    float sizeY;
    float x3;
    float y3;
    unsigned int ignored4[3];
}
@end

@implementation GSEventProxy

@end

@interface UIEvent (Creation)

- (id)_initWithEvent:(GSEventProxy *)fp8 touches:(id)fp12;

@end

@implementation UIEvent (MPSpecs)

- (id)initWithTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:touch.window];
    GSEventProxy *gsEventProxy = [[GSEventProxy alloc] init];
    gsEventProxy->x1 = location.x;
    gsEventProxy->y1 = location.y;
    gsEventProxy->x2 = location.x;
    gsEventProxy->y2 = location.y;
    gsEventProxy->x3 = location.x;
    gsEventProxy->y3 = location.y;
    gsEventProxy->sizeX = 1.0;
    gsEventProxy->sizeY = 1.0;
    gsEventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
    gsEventProxy->type = 3001;

    //
    // On SDK versions 3.0 and greater, we need to reallocate as a
    // UITouchesEvent.
    //
    Class touchesEventClass = objc_getClass("UITouchesEvent");
    if (touchesEventClass && ![[self class] isEqual:touchesEventClass])
    {
        self = [touchesEventClass alloc];
    }

    self = [self _initWithEvent:gsEventProxy touches:[NSSet setWithObject:touch]];
    if (self != nil)
    {
    }
    return self;
}

@end
