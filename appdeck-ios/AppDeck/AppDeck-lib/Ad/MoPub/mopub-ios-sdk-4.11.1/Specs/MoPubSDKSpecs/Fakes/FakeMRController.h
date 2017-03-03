//
//  FakeMRController.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRController.h"

@interface FakeMRController : MRController

@property (nonatomic, copy) NSString *loadedHTMLString;
@property (nonatomic, assign) BOOL userInteractedWithWebViewOverride;

@end
