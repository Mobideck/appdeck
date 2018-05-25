//
//  Singleton.h
//  AppDeck
//
//  Created by hanine ben saad on 17/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoaderViewController;
@interface Singleton : NSObject

+(Singleton*)sharedInstance;
-(UIImage*)getIconFromName:(NSString*)icon withLoader:(LoaderViewController*)loader;

@end
