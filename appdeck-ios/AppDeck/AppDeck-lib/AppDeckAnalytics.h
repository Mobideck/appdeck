//
//  AppDeckAnalytics.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/07/2015.
//  Copyright (c) 2015 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoaderViewController;

@protocol GAITracker;

@interface AppDeckAnalytics : NSObject

-(id)initWithLoader:(LoaderViewController *)loader;

-(void)sendEventWithName:(NSString *)name action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

-(void)sendScreenView:(NSString *)relativePath;

@property (nonatomic, weak) LoaderViewController *loader;

@property(nonatomic, retain) id<GAITracker> GATracker;
@property(nonatomic, retain) id<GAITracker> GAGlobalTracker;


@end
