//
//  ScreenConfiguration.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoaderViewController;

@interface ScreenConfiguration : NSObject

@property (strong, nonatomic) NSString          *title;
@property (strong, nonatomic) NSString          *logo;
@property (strong, nonatomic) NSString          *type;

@property (assign, nonatomic) BOOL              isPopUp;
@property (assign, nonatomic) BOOL              enableShare;

@property (strong, nonatomic) NSMutableArray    *urlRegex;
@property (strong, nonatomic) NSMutableArray    *urlRegexStrings;

@property (assign, nonatomic) long         ttl;

@property (weak, nonatomic) LoaderViewController         *loader;

+(ScreenConfiguration *)defaultConfigurationWitehLoader:(LoaderViewController *)loader;
-(id)initWithConfiguration:(NSDictionary *)configuration loader:(LoaderViewController *)loader;

-(BOOL)matchThisConfiguration:(NSURL *)url;
-(BOOL)isRelated:(NSURL *)url;

@end
