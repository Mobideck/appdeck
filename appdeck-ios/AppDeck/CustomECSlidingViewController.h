//
//  CustomECSlidingViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 28/11/2015.
//  Copyright © 2015 Mathieu De Kermadec. All rights reserved.
//

#import "ECSlidingViewController.h"

/** Notification that gets posted when the underRight view will appear */
extern NSString *const ECSlidingViewUnderRightWillAppear;

/** Notification that gets posted when the underLeft view will appear */
extern NSString *const ECSlidingViewUnderLeftWillAppear;

/** Notification that gets posted when the underLeft view will disappear */
extern NSString *const ECSlidingViewUnderLeftWillDisappear;

/** Notification that gets posted when the underRight view will disappear */
extern NSString *const ECSlidingViewUnderRightWillDisappear;

/** Notification that gets posted when the top view is anchored to the left side of the screen */
extern NSString *const ECSlidingViewTopDidAnchorLeft;

/** Notification that gets posted when the top view is anchored to the right side of the screen */
extern NSString *const ECSlidingViewTopDidAnchorRight;

/** Notification that gets posted when the top view will be centered on the screen */
extern NSString *const ECSlidingViewTopWillReset;

/** Notification that gets posted when the top view is centered on the screen */
extern NSString *const ECSlidingViewTopDidReset;

@class LoaderViewController;

@interface CustomECSlidingViewController : ECSlidingViewController
{
    BOOL shouldSendNotification;
}
@property (weak, nonatomic) LoaderViewController *loader;

// emulate features of ECSlidingViewController 1.0

@property (nonatomic,copy) void (^topViewCenterMoved)(float xPos);

@end
