//
//  FakeAdEngine.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdEngine.h"

@class AppDeckAdViewController;

@interface HTMLChunkAdEngine : AppDeckAdEngine

@property (nonatomic, retain) NSMutableDictionary *carrierInfo;

@end
