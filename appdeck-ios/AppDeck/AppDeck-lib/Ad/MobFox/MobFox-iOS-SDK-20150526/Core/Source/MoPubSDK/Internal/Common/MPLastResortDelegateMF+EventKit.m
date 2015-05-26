//
//  MPLastResortDelegate+EventKit.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPLastResortDelegateMF+EventKit.h"
#import "MPGlobalMF.h"
#import "UIViewController+MPAdditionsMF.h"


@implementation MPLastResortDelegateMF (EventKit)

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [controller mp_dismissModalViewControllerAnimated:MP_ANIMATED];
}

@end
