//
//  GSFullscreenAd.h
//  ConversantSDK
//
//  Copyright 2014 Conversant
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GSAd.h"

#ifndef GS_PUBLIC
#ifndef _GSAdModel_h_included_
#define _GSAdModel_h_included_
@interface GSAdModel : NSObject <GSAd, UIWebViewDelegate>
@end
#endif
#else
#import "GSAdModel.h"
#endif

typedef enum GSDeviceOrientation 
{
    kGSOrientationUnknown = 0,
    kGSOrientationLandscape,
    kGSOrientationPortrait
} GSDeviceOrientation;

/**
 * A subclass of the GSAdModel that implements all fullscreen ad-specific
 * functionality.
 */
@interface GSFullscreenAd : GSAdModel
{
    BOOL m_lockedOrientation;
    GSDeviceOrientation m_gsOrientation;
    UIInterfaceOrientation m_interfaceOrientation;

    BOOL m_isDisplayingBrowser;
}

@property (readonly) BOOL lockedOrientation;
@property (readonly) GSDeviceOrientation gsOrientation;
@property (readonly) UIInterfaceOrientation interfaceOrientation;
@property (readonly) BOOL isDisplayingBrowser;

/**
 * Initialize a GSFullscreenAd with a delegate. If this init is used, the
 * host app must implement the GUID method.
 */
- (id)initWithDelegate:(id<GSAdDelegate>)a_delegate;

/**
 * Initialize a GSFullscreenAd with a delegate and a GUID. If the host app does
 * not implement the GUID method, this is the init method that needs to be called.
 * Otherwise an exception will be raised.
 */
- (id)initWithDelegate:(id<GSAdDelegate>)a_delegate GUID:(NSString *)a_GUID;

/**
 * Tells the shared GSFullscreenAdViewController to display the ad.
 */
- (BOOL)displayFromViewController:(UIViewController *)a_viewController;

/**
 * Called when the interface orientation changes to broadcast the event to the client.
 */
- (void)didChangeToInterfaceOrientation:(UIInterfaceOrientation)a_interfaceOrientation gsOrientation:(GSDeviceOrientation) a_gsOrientation;

@end
