//
//  AppsFireAdEngine.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 25/12/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdEngine.h"
#import "appsfire-sdk-2.3.1/AppsfireSDK.h"
#import "appsfire-sdk-2.3.1/AppsfireAdSDK.h"

@interface AppsFireAdEngine : AppDeckAdEngine

@property (nonatomic, strong)   NSString *api_key;

@property (nonatomic, assign)   AFAdSDKModalType type;

@end
