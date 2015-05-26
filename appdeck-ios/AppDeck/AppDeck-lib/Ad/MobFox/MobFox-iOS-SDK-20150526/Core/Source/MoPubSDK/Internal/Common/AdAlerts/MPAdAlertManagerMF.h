//
//  MPAdAlertManager.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MPGlobalMF.h"

@class CLLocation;
@protocol MPAdAlertManagerDelegateMF;

@class MPAdConfigurationMF;

@interface MPAdAlertManagerMF : NSObject <MPAdAlertManagerProtocolMF>

@end

@protocol MPAdAlertManagerDelegateMF <NSObject>

@required
- (UIViewController *)viewControllerForPresentingMailVC;
- (void)adAlertManagerDidTriggerAlert:(MPAdAlertManagerMF *)manager;

@optional
- (void)adAlertManagerDidProcessAlert:(MPAdAlertManagerMF *)manager;

@end