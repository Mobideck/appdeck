//
//  LoaderConfiguration.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 01/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "LoaderConfiguration.h"
#import "NSDictionary+query.h"
#import "NSString+UIColor.h"
#import "ScreenConfiguration.h"
#import "UIImage+Resize.h"
#import "AppDeck.h"
#import "AppURLCache.h"
#import "IOSVersion.h"
#import "LoaderViewController.h"
#import "RE2Regexp.h"

@implementation LoaderConfiguration

-(id)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

-(void)readColor:(id)value intoColor1:(UIColor * __strong *)color1 intoColor2:(UIColor * __strong *)color2
{
    if (value == nil)
    {
        *color1 = [UIColor whiteColor];
        *color2 = *color1;
    }
    else if ([[value class] isSubclassOfClass:[NSArray class]] && [value count] == 2)
    {
        [self readColor:[value objectAtIndex:0] intoColor1:color1 intoColor2:nil];
        [self readColor:[value objectAtIndex:1] intoColor1:color2 intoColor2:nil];
    }
    else
    {
        NSString *color = [NSString stringWithFormat:@"%@", value];
        *color1 = [color toUIColor];
        if (color2)
            *color2 = *color1;
    }
}

-(BOOL)loadWithURL:(NSURL *)url result:(NSDictionary *)result loader:(LoaderViewController *)loader
{
    self.loader = loader;
    
    self.jsonUrl = url;
    
    self.app_version = [[result query:@"version"] integerValue];
    self.app_api_key = [result query:@"api_key"];

    self.baseUrl = url;
    if ([result query:@"base_url"])
    {
        NSString *baseUrlTmp = [result query:@"base_url"];
        if (!([baseUrlTmp hasPrefix:@"http://"] || [baseUrlTmp hasPrefix:@"https://"]))
            baseUrlTmp = [@"http://" stringByAppendingString:baseUrlTmp];
        NSURL *baseUrl = [NSURL URLWithString:baseUrlTmp];
        if (baseUrl)
            self.baseUrl = baseUrl;
    }

    self.enable_debug = [[result query:@"enable_debug"] boolValue];
    self.enable_clear_cache = [[result query:@"enable_clear_cache"] boolValue];
    if (self.loader.appDeck.isTestApp == YES)
        self.enable_debug = YES;
    if (self.loader.appDeck.isTestApp == YES)
        self.enable_clear_cache = YES;
    self.bootstrapUrl = [NSURL URLWithString:[result query:@"bootstrap.url"] relativeToURL:self.baseUrl];
    if (self.bootstrapUrl == nil)
        self.bootstrapUrl = [NSURL URLWithString:@"." relativeToURL:self.baseUrl];
    
    self.leftMenuUrl = [NSURL URLWithString:[result query:@"leftmenu.url"] relativeToURL:self.baseUrl];
    self.leftMenuWidth = [[result query:@"leftmenu.width"] floatValue];
    if (self.leftMenuWidth == 0)
        self.leftMenuWidth = 280;
    if (self.leftMenuWidth > 280)
        self.leftMenuWidth = 280;

    self.rightMenuUrl = [NSURL URLWithString:[result query:@"rightmenu.url"] relativeToURL:self.baseUrl];
    self.rightMenuWidth = [[result query:@"rightmenu.width"] floatValue];
    if (self.rightMenuWidth == 0)
        self.rightMenuWidth = 280;
    if (self.rightMenuWidth > 280)
        self.rightMenuWidth = 280;

    self.title = [result query:@"title"];
    
    [self readColor:[result query:@"app_color"] intoColor1:&_app_color1 intoColor2:&_app_color2];
    [self readColor:[result query:@"app_background_color"] intoColor1:&_app_background_color1 intoColor2:&_app_background_color2];
    [self readColor:[result query:@"leftmenu_background_color"] intoColor1:&_leftmenu_background_color1 intoColor2:&_leftmenu_background_color2];
    [self readColor:[result query:@"rightmenu_background_color"] intoColor1:&_rightmenu_background_color1 intoColor2:&_rightmenu_background_color2];
    
    self.control_color = [[result query:@"control_color"] toUIColor];
    self.button_color = [[result query:@"button_color"] toUIColor];
    
    [self readColor:[result query:@"app_topbar_color"] intoColor1:&_topbar_color1 intoColor2:&_topbar_color2];
    
    AppDeck *app = [AppDeck sharedInstance];
    
    self.cache = [[NSMutableArray alloc] init];
    for (NSString *regexp in result[@"cache"])
    {
        [self.cache addObject:regexp];
        [app.cache addCacheRegularExpressionFromString:regexp];
    }
    
    // adBlock
    self.adBlock = [[result query:@"adBlock"] boolValue];
    app.cache.enableAdBlock = self.adBlock;
    self.adBlockWhiteList = [[NSMutableArray alloc] init];
    for (NSString *regexp in result[@"adBlockWhiteList"])
    {
        [self.adBlockWhiteList addObject:regexp];
        [app.cache addAdBlockWhiteListCacheRegularExpressionFromString:regexp];
    }
    for (NSString *regexp in result[@"adBlockBlackList"])
    {
        [self.adBlockBlackList addObject:regexp];
        [app.cache addAdBlockBlackListCacheRegularExpressionFromString:regexp];
    }
    
    // other Domain
    self.otherDomainRegex = [[NSMutableArray alloc] init];
    self.otherDomainRegexStrings = [[NSMutableArray alloc] init];
    for (NSString *regexString in result[@"other_domain"])
    {
        if (regexString.length == 0)
            continue;
        RE2Regexp *regex = [[RE2Regexp alloc] initWithString:regexString];
        if (regex == nil)
        {
            NSLog(@"invalid Rexep URL : %@", regexString);
            continue;
        }
        [self.otherDomainRegex addObject:regex];
        [self.otherDomainRegexStrings addObject:regexString];
    }
    
    // *** CDN ***
    
    self.cdn_enabled = [[result query:@"cdn_enabled"] boolValue];
    // we disable auto appdeck CDN features
    /*    if (self.app_api_key)
    {
        self.cdn_host = [NSString stringWithFormat:@"%@.appdeckcdn.com", self.app_api_key];
//        self.cdn_host = @"cdn.appdeck.mobi";
//        self.cdn_path = [NSString stringWithFormat:@"/%@", self.app_api_key];
        self.cdn_path = @"";
    }*/
    if ([result query:@"cdn_host"])
        self.cdn_host = [result query:@"cdn_host"];
    if ([result query:@"cdn_path"])
        self.cdn_path = [result query:@"cdn_path"];
    if (self.cdn_host == nil || [self.cdn_host isEqualToString:@""])
        self.cdn_enabled = NO;
    
    // ** SCREEN CONFIGURATION **
    
    self.screenConfigurations = [[NSMutableArray alloc] init];
    for (NSDictionary *screen in result[@"screens"]) {
        ScreenConfiguration *screenConfiguration = [[ScreenConfiguration alloc] initWithConfiguration:screen loader:self.loader];
        [self.screenConfigurations addObject:screenConfiguration];
    }
    
    self.prefetch_url = [NSURL URLWithString:[result query:@"prefetch_url"] relativeToURL:self.baseUrl];
    if (self.prefetch_url == nil && self.app_api_key != nil)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
//            self.prefetch_url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.appdeckcdn.com/%@_tablet.7z", self.app_api_key, self.app_api_key]];
            self.prefetch_url = [NSURL URLWithString:[NSString stringWithFormat:@"http://prefetch.appdeck.mobi/%@_tablet.7z", self.app_api_key]];
        }
        else
        {
//            self.prefetch_url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@.appdeckcdn.com/%@.7z", self.app_api_key, self.app_api_key]];
            self.prefetch_url = [NSURL URLWithString: [NSString stringWithFormat:@"http://prefetch.appdeck.mobi/%@.7z", self.app_api_key]];
        }
    }
    
    self.prefetch_ttl = [[result query:@"prefetch_ttl"] intValue];
    
    if (self.prefetch_url != nil)
    {
        if (self.prefetch_ttl == 0)
            self.prefetch_ttl = 600;
    }
    
/*    if (NO_PUB == NO)
    {
        self.mobiclickApplicationId = [result query:@"ad.mobiclick.applicationId"];
        self.mobiclickAdMobSub = [result query:@"ad.mobiclick.adMobSub"];
    }*/

    // ** Google Analytics **
    
    self.ga = [result query:@"ga"];
    
    // push register
    self.push_register_url = [NSURL URLWithString:[result query:@"push_register"] relativeToURL:self.baseUrl];
    if (self.push_register_url == nil)
        self.push_register_url = [NSURL URLWithString:@"http://push.appdeck.mobi/register"];
    
    self.embed_url = [NSURL URLWithString:[result query:@"embed_url"] relativeToURL:self.baseUrl];

    self.embed_runtime_url = [NSURL URLWithString:[result query:@"embed_runtime_url"] relativeToURL:self.baseUrl];
    
    // images and icons
    
    self.enable_mobilize = [[result query:@"enable_mobilize"] boolValue];

    // MUST do image doawload at end to take advantage of cache
    
    if ([result query:@"logo"] != nil)
        self.logo = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"logo"] relativeToURL:self.baseUrl] height:44];
    
    // icon theme
    NSString *icon_theme_str = [result query:@"icon_theme"];
    if (icon_theme_str != nil && [[icon_theme_str lowercaseString] isEqualToString:@"dark"])
        self.icon_theme = IconThemeDark;
    else if (icon_theme_str != nil && [[icon_theme_str lowercaseString] isEqualToString:@"light"])
        self.icon_theme = IconThemeLight;
    else
        self.icon_theme = IconThemeDark;

    // light theme
    if (self.icon_theme == IconThemeDark)
    {
        self.icon_menu = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_menu" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/menu.png"] relativeToURL:self.baseUrl] height:44];
        
        self.image_loader = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"image_loader" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/images/loader.png"] relativeToURL:self.baseUrl] height:66];
        self.image_pull_arrow = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"image_pull_arrow" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/images/pull_arrow.png"] relativeToURL:self.baseUrl] height:66];
        
        self.icon_action = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_action" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/action.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_ok = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_ok" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/ok.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_cancel = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_cancel" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/cancel.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_close = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_close" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/close.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_config = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_config" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/config.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_info = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_info" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/info.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_next = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_next" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/next.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_previous = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_previous" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/previous.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_up = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_up" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/up.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_down = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_down" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/down.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_refresh = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_refresh" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/refresh.png"] relativeToURL:self.baseUrl] height:44];

        self.icon_search = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_search" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/search.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_user = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_user" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/user.png"] relativeToURL:self.baseUrl] height:44];
    } else {
        self.icon_menu = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_menu" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/menu_dark.png"] relativeToURL:self.baseUrl] height:44];
        
        self.image_loader = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"image_loader" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/images/loader_dark.png"] relativeToURL:self.baseUrl] height:66];
        self.image_pull_arrow = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"image_pull_arrow" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/images/pull_arrow_dark.png"] relativeToURL:self.baseUrl] height:66];
        
        self.icon_action = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_action" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/action_dark.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_ok = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_ok" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/ok_dark.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_cancel = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_cancel" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/cancel_dark.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_close = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_close" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/close_dark.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_config = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_config" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/config_dark.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_info = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_info" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/info_dark.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_next = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_next" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/next_dark.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_previous = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_previous" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/previous_dark.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_up = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_up" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/up_dark.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_down = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_down" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/down_dark.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_refresh = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_refresh" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/refresh_dark.png"] relativeToURL:self.baseUrl] height:44];

        self.icon_search = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_search" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/search_dark.png"] relativeToURL:self.baseUrl] height:44];
        self.icon_user = [[ImagePreload alloc] initWithURL:[NSURL URLWithString:[result query:@"icon_user" defaultValue:@"http://appdata.static.appdeck.mobi/res/ios7/icons/user_dark.png"] relativeToURL:self.baseUrl] height:44];
    }
    self.image_network_error_url = [result query:@"image_network_error" defaultValue:@"http://appdata.static.appdeck.mobi/default/images/network_error.png"];
    [self readColor:[result query:@"image_network_error_background_color"] intoColor1:&_image_network_error_background_color1 intoColor2:&_image_network_error_background_color2];
    
    [self.logo preload];
    [self.icon_action preload];
    [self.icon_ok preload];
    [self.icon_cancel preload];
    [self.icon_close preload];
    [self.icon_config preload];
    [self.icon_info preload];
    [self.icon_menu preload];
    [self.icon_next preload];
    [self.icon_previous preload];
    [self.icon_refresh preload];
    [self.icon_search preload];
    [self.icon_up preload];
    [self.icon_down preload];
    [self.icon_user preload];
    [self.image_loader preload];
    [self.image_pull_arrow preload];
    
    return YES;
}

- (UIImage *)scaledImage:(UIImage *)image
{
    CGRect rect = CGRectMake(0.0, 0.0, image.size.width / 2, image.size.height / 2); //Change the size of the image
    UIGraphicsBeginImageContext(rect.size);
    
    [image drawInRect:rect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return scaledImage;
}

-(UIImage *)loadImageWithName:(NSString *)name defaultURL:(NSString *)defaultURL baseURL:(NSURL *)url height:(CGFloat)height result:(NSDictionary *)result
{
    NSString *image_url = [result query:name];
    if (image_url == nil)
        image_url = defaultURL;
    if (image_url == nil)
        return nil;
    
    // download image
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:image_url relativeToURL:url]] returningResponse:&response error:&error];
    UIImage *image = [UIImage imageWithData:data];
    
    image = [image retinaEnabledImageScaledToFitHeight:height];
    
    
//    image = [UIImage imageWithCGImage:image.CGImage scale:2.0 orientation:UIImageOrientationUp];
    return image;
/*    if (logo)
    {
        NSInteger maxLogoHeight = 44 * [[UIScreen mainScreen] scale];
        if (logo.size.height > maxLogoHeight) {
            logo = [logo scaleToSize:CGSizeMake(logo.size.width * maxLogoHeight / logo.size.height, maxLogoHeight)];
        }
        if ([[UIScreen mainScreen] scale] == 2)
            logo = [UIImage imageWithCGImage:logo.CGImage scale:2.0 orientation:UIImageOrientationUp];
    }*/
    
}

@end
