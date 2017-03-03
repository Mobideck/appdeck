//
//  FakeMRBridge.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MRBridge+MPSpecs.h"

@class MRProperty;

@interface FakeMRBridge : MRBridge <MPWebViewDelegate>

@property (nonatomic, assign) BOOL didFireReadyEvent;
@property (nonatomic, strong) NSMutableSet *changedProperties;
@property (nonatomic, strong) NSMutableArray *errorEvents;
@property (nonatomic, copy) NSString *lastCompletedCommand;

- (BOOL)containsProperty:(MRProperty *)property;

@end
