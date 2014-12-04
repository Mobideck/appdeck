//
//  KeyboardStateListener.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 03/02/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import "KeyboardStateListener.h"
#import "AppDeck.h"
#import "LoaderViewController.h"
#import "LoaderChildViewController.h"

static KeyboardStateListener *sharedObj;

@implementation KeyboardStateListener

/*+ (KeyboardStateListener *)sharedInstance
{
    return sharedObj;
}
+ (void)load
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    sharedObj = [[self alloc] init];
    [pool release];
}*/

- (BOOL)isVisible
{
    return _isVisible;
}

- (void)didShow:(NSNotification *)notification
{
    _isVisible = YES;
    // Step 1: Get the size of the keyboard.
    _keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [[[AppDeck sharedInstance].loader getCurrentChild] viewWillLayoutSubviews];
}

- (void)didHide:(NSNotification *)notification
{
    _isVisible = NO;
    [[[AppDeck sharedInstance].loader getCurrentChild] viewWillLayoutSubviews];
}

- (CGSize)getKeyboardSize
{
    return _keyboardSize;
}

- (id)init
{
    if ((self = [super init]))
    {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didShow:) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(didHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
