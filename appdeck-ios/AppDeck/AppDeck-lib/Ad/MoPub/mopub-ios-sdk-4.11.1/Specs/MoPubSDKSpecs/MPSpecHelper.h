//
//  MPSpecHelper.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FakeMPAdServerCommunicator.h"
#import "InterstitialIntegrationSharedBehaviors.h"
#import "Foundation+PivotalSpecHelper.h"
#import "UIKit+PivotalSpecHelper.h"
#import "UIKit+PivotalSpecHelperStubs.h"
#import "NSURLConnection+MPSpecs.h"
#import "UIApplication+MPSpecs.h"
#import "MPStoreKitProvider+MPSpecs.h"
#import "FakeMPInstanceProvider.h"
#import "FakeMPCoreInstanceProvider.h"
#import "NSErrorFactory.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define _IP(row, section) [NSIndexPath indexPathForRow:row inSection:section]

@protocol CedarDouble;

typedef void (^NoArgBlock)();
typedef id (^IDReturningBlock)();

void verify_fake_received_selectors(id<CedarDouble> fake, NSArray *selectors);
void verify_fake_received_selectors_async(id<CedarDouble> fake, NSArray *selectors);
void log_sent_messages(id<CedarDouble> fake);
NSData *dataFromXMLFileNamed(NSString *name);

extern FakeMPInstanceProvider *fakeProvider;
extern FakeMPCoreInstanceProvider *fakeCoreProvider;
extern NSString *kMPSpecsTestImageURL;

@interface MPSpecHelper : NSObject

@end
