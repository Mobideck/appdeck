//
// Copyright (c) 2013 MoPub. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface FakeEKEventStore : EKEventStore

@property (nonatomic, copy) EKEventStoreRequestAccessCompletionHandler requestAccessCompletionHandler;
@property (nonatomic, strong) EKEvent *lastSavedEvent;
@property (nonatomic, assign) BOOL shouldFailToSaveEvent;

- (void)simulateGrantingAccess;
- (void)simulateDenyingAccess;

@end
