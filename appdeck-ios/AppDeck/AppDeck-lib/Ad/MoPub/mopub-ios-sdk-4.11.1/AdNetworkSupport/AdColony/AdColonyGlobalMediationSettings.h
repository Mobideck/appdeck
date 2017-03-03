//
//  AdColonyGlobalMediationSettings.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPMediationSettingsProtocol.h"
#endif

/*
 * `AdColonyGlobalMediationSettings` allows the application to provide constant global properties
 * to configure aspects of Ad Colony. See `MPMediationSettingsProtocol` to see how mediation settings
 * are used.
 */
@interface AdColonyGlobalMediationSettings : NSObject <MPMediationSettingsProtocol>

/*
 * Sets the customId to utilize server-side mode for AdColony V4VC.
 */
@property (nonatomic, copy) NSString *customId;

@end
