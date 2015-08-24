//
//  MPLastResortDelegate+EventKit.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPLastResortDelegate+EventKit.h"
#import "MPGlobal.h"


@implementation MPLastResortDelegate (EventKit)

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [controller dismissViewControllerAnimated:MP_ANIMATED completion:nil];
}

@end
