//
//  MPLastResortDelegate.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPLastResortDelegateMF.h"
#import "MPGlobalMF.h"
#import "UIViewController+MPAdditionsMF.h"

@class MFMailComposeViewController;

@implementation MPLastResortDelegateMF

+ (id)sharedDelegate
{
    static MPLastResortDelegateMF *lastResortDelegate;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        lastResortDelegate = [[self alloc] init];
    });
    return lastResortDelegate;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(NSInteger)result error:(NSError*)error
{
    [controller mp_dismissModalViewControllerAnimated:MP_ANIMATED];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController mp_dismissModalViewControllerAnimated:MP_ANIMATED];
}
#endif

@end
