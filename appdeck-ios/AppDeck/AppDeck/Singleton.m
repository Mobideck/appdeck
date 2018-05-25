//
//  Singleton.m
//  AppDeck
//
//  Created by hanine ben saad on 17/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "Singleton.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"

static Singleton*shared;

@implementation Singleton


+(Singleton*)sharedInstance
{
    if (!shared) {
        shared=[[Singleton alloc]init];
    }
    return shared;
}

-(UIImage*)getIconFromName:(NSString*)icon withLoader:(LoaderViewController*)loader
{
    UIImage *iconImage = loader.conf.icon_action.image;

        if ([icon isEqualToString:@"!action"])
            iconImage = loader.conf.icon_action.image;
        if ([icon isEqualToString:@"!ok"])
            iconImage = loader.conf.icon_ok.image;
        if ([icon isEqualToString:@"!cancel"])
            iconImage = loader.conf.icon_cancel.image;
        if ([icon isEqualToString:@"!close"])
            iconImage = loader.conf.icon_close.image;
        if ([icon isEqualToString:@"!config"])
            iconImage = loader.conf.icon_config.image;
        if ([icon isEqualToString:@"!info"])
            iconImage = loader.conf.icon_info.image;
        if ([icon isEqualToString:@"!menu"])
            iconImage = loader.conf.icon_menu.image;
        if ([icon isEqualToString:@"!next"])
            iconImage = loader.conf.icon_next.image;
        if ([icon isEqualToString:@"!previous"])
            iconImage = loader.conf.icon_previous.image;
        if ([icon isEqualToString:@"!refresh"])
            iconImage = loader.conf.icon_refresh.image;
        if ([icon isEqualToString:@"!search"])
            iconImage = loader.conf.icon_search.image;
        if ([icon isEqualToString:@"!up"])
            iconImage = loader.conf.icon_up.image;
        if ([icon isEqualToString:@"!down"])
            iconImage = loader.conf.icon_down.image;
        if ([icon isEqualToString:@"!user"])
            iconImage = loader.conf.icon_user.image;
        
        return iconImage;
        
}

@end
