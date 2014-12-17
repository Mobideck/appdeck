//
// Copyright (c) 2013 MoPub. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "MRJavaScriptEventEmitter.h"

@class MRProperty;

@interface FakeMRJavaScriptEventEmitter : MRJavaScriptEventEmitter

@property (nonatomic, assign) BOOL didFireReadyEvent;
@property (nonatomic, strong) NSMutableSet *changedProperties;
@property (nonatomic, strong) NSMutableArray *errorEvents;
@property (nonatomic, copy) NSString *lastCompletedCommand;

- (BOOL)containsProperty:(MRProperty *)property;

@end
