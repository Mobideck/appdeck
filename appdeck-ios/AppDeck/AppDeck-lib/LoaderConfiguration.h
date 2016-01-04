//
//  LoaderConfiguration.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 01/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImagePreload.h"

@class LoaderViewController;

typedef enum {
    IconThemeLight,
    IconThemeDark
} IconTheme;

@interface LoaderConfiguration : NSObject

// store app conf
@property (strong, nonatomic) NSURL *jsonUrl;

@property (strong, nonatomic) NSURL *baseUrl;

@property (assign, nonatomic) long app_version;

@property (strong, nonatomic) NSString *app_api_key;

@property (assign, nonatomic) BOOL enable_debug;
@property (assign, nonatomic) BOOL enable_clear_cache;

@property (strong, nonatomic) NSURL *app_base_url;
@property (strong, nonatomic) NSURL *app_conf_url;
@property (strong, nonatomic) NSURL *push_register_url;

@property (strong, nonatomic) NSURL *bootstrapUrl;
@property (strong, nonatomic) NSURL *leftMenuUrl;
@property (assign, nonatomic) CGFloat leftMenuWidth;
//@property (assign, nonatomic) CGFloat leftMenuReveal;
@property (strong, nonatomic) NSURL *rightMenuUrl;
@property (assign, nonatomic) CGFloat rightMenuWidth;
//@property (assign, nonatomic) CGFloat rightMenuReveal;

@property (strong, nonatomic) UIColor *app_color;

//@property (strong, nonatomic) UIColor *app_color1;
//@property (strong, nonatomic) UIColor *app_color2;
@property (strong, nonatomic) UIColor *app_topbar_color1;
@property (strong, nonatomic) UIColor *app_topbar_color2;

@property (strong, nonatomic) UIColor *app_topbar_text_color;

@property (strong, nonatomic) UIColor *app_background_color1;
@property (strong, nonatomic) UIColor *app_background_color2;
@property (strong, nonatomic) UIColor *leftmenu_background_color1;
@property (strong, nonatomic) UIColor *leftmenu_background_color2;
@property (strong, nonatomic) UIColor *rightmenu_background_color1;
@property (strong, nonatomic) UIColor *rightmenu_background_color2;

//@property (strong, nonatomic) UIColor *control_color;
//@property (strong, nonatomic) UIColor *button_color;

@property (strong, nonatomic) NSString *title;

//@property (strong, nonatomic) NSString *logoUrl;
@property (strong, nonatomic) ImagePreload *logo;

@property (strong, nonatomic) NSMutableArray *cache;

@property (strong, nonatomic) NSMutableArray    *otherDomainRegex;
@property (strong, nonatomic) NSMutableArray    *otherDomainRegexStrings;


@property (assign, nonatomic) BOOL adBlock;
@property (strong, nonatomic) NSMutableArray *adBlockWhiteList;
@property (strong, nonatomic) NSMutableArray *adBlockBlackList;

@property (assign, nonatomic) long prefetch_ttl;

//@property (strong, nonatomic) UIView *statusBarInfo;


@property (strong, nonatomic) NSURL *prefetch_url;

@property (assign, nonatomic) IconTheme icon_theme;

// images and icons
/*
@property (strong, nonatomic) NSString *url_icon_action;
@property (strong, nonatomic) NSString *url_icon_cancel;
@property (strong, nonatomic) NSString *url_icon_close;
@property (strong, nonatomic) NSString *url_icon_menu;
@property (strong, nonatomic) NSString *url_icon_next;
@property (strong, nonatomic) NSString *url_icon_previous;
@property (strong, nonatomic) NSString *url_icon_up;
@property (strong, nonatomic) NSString *url_icon_down;
@property (strong, nonatomic) NSString *url_icon_refresh;
*/

/*@property (strong, nonatomic) NSURL *url_image_loader;
@property (strong, nonatomic) NSURL *url_image_pull_arrow;*/

@property (assign, nonatomic) BOOL          cdn_enabled;
@property (strong, nonatomic) NSString      *cdn_host;
@property (strong, nonatomic) NSString      *cdn_path;

@property (strong, nonatomic) ImagePreload *icon_action;
@property (strong, nonatomic) ImagePreload *icon_ok;
@property (strong, nonatomic) ImagePreload *icon_cancel;
@property (strong, nonatomic) ImagePreload *icon_close;
@property (strong, nonatomic) ImagePreload *icon_config;
@property (strong, nonatomic) ImagePreload *icon_info;
@property (strong, nonatomic) ImagePreload *icon_menu;
@property (strong, nonatomic) ImagePreload *icon_next;
@property (strong, nonatomic) ImagePreload *icon_previous;
@property (strong, nonatomic) ImagePreload *icon_refresh;
@property (strong, nonatomic) ImagePreload *icon_search;
@property (strong, nonatomic) ImagePreload *icon_up;
@property (strong, nonatomic) ImagePreload *icon_down;
@property (strong, nonatomic) ImagePreload *icon_user;
@property (strong, nonatomic) ImagePreload *image_loader;
@property (strong, nonatomic) ImagePreload *image_pull_arrow;

@property (strong, nonatomic) NSString *image_network_error_url;
@property (strong, nonatomic) UIColor *image_network_error_background_color1;
@property (strong, nonatomic) UIColor *image_network_error_background_color2;

@property (strong, nonatomic) NSMutableArray  *screenConfigurations;

@property (strong, nonatomic) NSString *mobiclickApplicationId;
@property (strong, nonatomic) NSString *mobiclickAdMobSub;

@property (strong, nonatomic) NSString *ga;
@property (strong, nonatomic) NSString *flurry;
@property (strong, nonatomic) NSString *facebook_app_id;
@property (strong, nonatomic) NSString *fabric_api_key;
@property (strong, nonatomic) NSString *fabric_build_secret;
@property (strong, nonatomic) NSString *twitter_consumer_key;
@property (strong, nonatomic) NSString *twitter_consumer_secret;

@property (strong, nonatomic) NSURL *embed_url;
@property (strong, nonatomic) NSURL *embed_runtime_url;

@property (assign, nonatomic) BOOL enable_mobilize;

@property (weak, nonatomic) LoaderViewController *loader;

-(BOOL)loadWithURL:(NSURL *)url result:(NSDictionary *)result loader:(LoaderViewController *)loader;

@end
