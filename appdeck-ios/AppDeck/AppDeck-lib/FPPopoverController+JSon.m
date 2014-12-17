//
//  FPPopoverController+JSon.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "FPPopoverController+JSon.h"
#import "NSError+errorWithFormat.h"
#import "ManagedUIWebViewController.h"
#import "LoaderChildViewController.h"
#import "JSONKit.h"
#import "NSString+UIColor.h"

@implementation FPPopoverController (JSon)

+(FPPopoverController *)popoverControllerFromJSon:(NSString *)json fromView:(UIView *)view relativeToURL:(NSURL *)base_url error:(NSError **)error
{
    NSMutableDictionary *infos = [[NSMutableDictionary alloc] init];
    
    NSArray *chunks = [json componentsSeparatedByString:@","];
    for (NSString *chunk in chunks)
    {
        NSArray *tmp = [chunk componentsSeparatedByString:@"="];
        if ([tmp count] == 2)
        {
            NSString *name = [[tmp objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *value = [[tmp objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [infos setObject:value forKey:name];
        }
    }
    
/*    json = [json stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    
    NSData *json_data = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    @try {
       
        infos = [json_data objectFromJSONDataWithParseOptions:JKParseOptionComments|JKParseOptionUnicodeNewlines|JKParseOptionLooseUnicode|JKParseOptionPermitTextAfterValidJSON error:error];
    }
    @catch (NSException *exception) {
        return nil;
    }*/
    
    if (infos == nil)
        return nil;
    
    //{url: 'menu.php', width: 250, height: 300, tint: 'light', arrow: 'up', title: 'My title', alpha: 0.8, border: false}
    
    NSString *url = [infos objectForKey:@"url"];
    if (url == nil)
    {
        if (error)
            *error = [NSError errorWithFormat:@"entry 'url' missing: %@", json];
        return nil;
    }
   
    // configuration
    CGFloat width = [[infos objectForKey:@"width"] floatValue];
    CGFloat height = [[infos objectForKey:@"height"] floatValue];
    CGFloat alpha = [[infos objectForKey:@"alpha"] floatValue];
    NSString *tint = [infos objectForKey:@"tint"];
    NSString *arrow = [infos objectForKey:@"arrow"];
    NSString *title = [infos objectForKey:@"title"];
    UIColor *bgcolor = [[infos objectForKey:@"bgcolor"] toUIColor];
    id border = [infos objectForKey:@"border"];
    //id radius = [infos objectForKey:@"radius"];

    ManagedUIWebViewController *ctl = [[ManagedUIWebViewController alloc] init];
//    ctl.title = title;
    FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:ctl];
    
    if (width == 0)
        width = 150;
    if (height == 0)
        height = 200;
    popover.contentSize = CGSizeMake(width, height);
    
    if ([tint isEqualToString:@"black"])
        popover.tint = FPPopoverBlackTint;
    if ([tint isEqualToString:@"light"])
        popover.tint = FPPopoverLightGrayTint;
    if ([tint isEqualToString:@"green"])
        popover.tint = FPPopoverGreenTint;
    if ([tint isEqualToString:@"red"])
        popover.tint = FPPopoverRedTint;
    if ([tint isEqualToString:@"white"])
        popover.tint = FPPopoverWhiteTint;    
    
    if ([arrow isEqualToString:@"up"])
        popover.arrowDirection = FPPopoverArrowDirectionUp;
    if ([arrow isEqualToString:@"down"])
        popover.arrowDirection = FPPopoverArrowDirectionDown;
    if ([arrow isEqualToString:@"none"])
        popover.arrowDirection = FPPopoverNoArrow;
    
    if (border != nil)
        popover.border = [border boolValue];
    
/*    if (radius != nil)
        popover.radius = [radius floatValue];*/
    
    if (alpha > 0)
        popover.alpha = alpha;
    
    
    [popover presentPopoverFromView:view];
    
    popover.title = title;
    
    if (bgcolor == nil)
        bgcolor = [UIColor clearColor];
    [ctl.webView setBackgroundColor:bgcolor];
    ctl.view.backgroundColor = bgcolor;

    [ctl setChromeless:YES];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url relativeToURL:base_url]];
    [ctl loadRequest:request
             progess:^(float percent) {}
           completed:^(NSError *error) {
           
               if (error != nil)
                   [popover dismissPopoverAnimated:YES];
               
           }];
    
    return popover;
}

@end
