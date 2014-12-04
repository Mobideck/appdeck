//
//  KeyboardStateListener.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 03/02/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyboardStateListener : NSObject {
    BOOL _isVisible;
    CGSize _keyboardSize;
}

//+ (KeyboardStateListener *) sharedInstance;

@property (nonatomic, readonly, getter=isVisible) BOOL visible;

@property (nonatomic, readonly, getter=getKeyboardSize) CGSize keyboardSize;

@end
