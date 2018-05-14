//
//  PageBarButtonItem.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 07/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "PageBarButton.h"
#import "LoaderViewController.h"
#import "PageViewController.h"
#import "LoaderConfiguration.h"
#import "AppDeck.h"
#import "AppURLCache.h"
#import "UIImage+Resize.h"

@implementation PageBarButton

-(id)initWithInfos:(id)infos andChild:(PageViewController *)child
{
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    self.type = UIButtonTypeCustom;
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    self.child = child;
    
    self.type = [infos objectForKey:@"type"];
    self.content = [infos objectForKey:@"content"];
    self.contentalt = [infos objectForKey:@"contentalt"];
    self.icon = [infos objectForKey:@"icon"];
    self.iconalt = [infos objectForKey:@"iconalt"];
    if ([infos objectForKey:@"badge"] != nil)
        self.badgeValue = [infos objectForKey:@"badge"];
    
    NSString *enabled = [infos objectForKey:@"enabled"];
    if (enabled != nil && ([enabled isEqualToString:@"no"] || [enabled isEqualToString:@"false"] || [enabled isEqualToString:@"0"]))
        self.enabled = NO;
    
    if (![self.type isEqualToString:@"button"] && ![self.type isEqualToString:@"toggle"] && [self.type isEqualToString:@"search"])
    {
        self.type = @"button";
    }
    
    [self loadInfos];
    [self setImageEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
    return self;
}

-(void)setImageFromData:(NSData *)data forState:(UIControlState)state
{
    NSLog(@"XXXXXX image size: %lu", data.length);
    
    UIImage *buttonImage = [UIImage imageWithData:data scale:UIScreen.mainScreen.scale];

    CGFloat height = self.child.navigationController.navigationBar.frame.size.height;

    if (buttonImage)
    {
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, height, height)];
        [self setImage:buttonImage forState:state];
        [self setImageEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
    }
    else
        NSLog(@"bad icon image");
    
    [self adjustBadgeView];
}

-(void)downloadImage:(NSString *)url forState:(UIControlState)state
{
    NSLog(@"url %@",self.child.url);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url relativeToURL:self.child.url]];
    
    NSCachedURLResponse *cachedResponse = [self.child.loader.appDeck.cache getCacheResponseForRequest:request];
    
    if (cachedResponse)
    {
        [self setImageFromData:cachedResponse.data forState:state];
    }
    else
    {
        UIImage *buttonImage = [[UIImage alloc] init];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, buttonImage.size.width, buttonImage.size.height)];
        [self setImage:buttonImage forState:state];
        [self setImageEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [self setImageFromData:data forState:state];
                    [self.superview setNeedsLayout];
                });
         
            }
            else
            NSLog(@"Failed to download icon: %@: %@", url, error);
        }];
        
        [task resume];

    }
}

-(void)loadInfos
{
    [self addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

    if (self.icon == nil)
        return;
    
    NSString *icon = self.icon;
    NSString *iconalt = self.iconalt;
    
    if ([self.icon hasPrefix:@"!"])
    {
        UIImage *iconImage = self.child.loader.conf.icon_action.image;
        if ([self.icon isEqualToString:@"!action"])
            iconImage = self.child.loader.conf.icon_action.image;
        if ([self.icon isEqualToString:@"!ok"])
            iconImage = self.child.loader.conf.icon_ok.image;
        if ([self.icon isEqualToString:@"!cancel"])
            iconImage = self.child.loader.conf.icon_cancel.image;
        if ([self.icon isEqualToString:@"!close"])
            iconImage = self.child.loader.conf.icon_close.image;
        if ([self.icon isEqualToString:@"!config"])
            iconImage = self.child.loader.conf.icon_config.image;
        if ([self.icon isEqualToString:@"!info"])
            iconImage = self.child.loader.conf.icon_info.image;
        if ([self.icon isEqualToString:@"!menu"])
            iconImage = self.child.loader.conf.icon_menu.image;
        if ([self.icon isEqualToString:@"!next"])
            iconImage = self.child.loader.conf.icon_next.image;
        if ([self.icon isEqualToString:@"!previous"])
            iconImage = self.child.loader.conf.icon_previous.image;
        if ([self.icon isEqualToString:@"!refresh"])
            iconImage = self.child.loader.conf.icon_refresh.image;
        if ([self.icon isEqualToString:@"!search"])
            iconImage = self.child.loader.conf.icon_search.image;
        if ([self.icon isEqualToString:@"!up"])
            iconImage = self.child.loader.conf.icon_up.image;
        if ([self.icon isEqualToString:@"!down"])
            iconImage = self.child.loader.conf.icon_down.image;
        if ([self.icon isEqualToString:@"!user"])
            iconImage = self.child.loader.conf.icon_user.image;

        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, iconImage.size.width, iconImage.size.height)];
        [self setImage:iconImage forState:UIControlStateNormal];
        [self setImageEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
        
        [self adjustBadgeView];
        return;
    }
    
    if (self.icon)
        [self downloadImage:icon forState:UIControlStateNormal];

    if (self.iconalt)
        [self downloadImage:iconalt forState:UIControlStateHighlighted];
}


-(void)buttonAction:(UIButton*)button
{
    UIView *save = self.child.focus;
    self.child.focus = self;
    [self.child load:self.content];
    self.child.focus = save;
}

-(void)adjustBadgeView
{
    if (badgeView == nil)
        return;
    [badgeView removeFromSuperview];
    if (self.imageView == nil)
        return;
    [self.imageView addSubview:badgeView];
    self.imageView.clipsToBounds = NO;
}

-(void)setBadgeValue:(NSString *)badgeValue
{
    _badgeValue = badgeValue;
    if (badgeView == nil)
    {
        badgeView = [[JSBadgeView alloc] initWithParentView:self alignment:JSBadgeViewAlignmentTopRight];
        /*
        badgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake( -37, -20, 74, 40)];
        badgeView.shadow = NO;
        badgeView.shine = YES;
        badgeView.strokeWidth = 1.0;
        [self adjustBadgeView];*/
    }
    badgeView.badgeText = _badgeValue;
//    badgeView.value = _badgeValue;
}
@end
