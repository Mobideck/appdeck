//
//  AppDeckPlugin.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/05/2016.
//  Copyright © 2016 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDeckAPICall.h"

@interface AppDeckPlugin : NSObject

-(BOOL)apiCall:(AppDeckApiCall *)call;

@end
