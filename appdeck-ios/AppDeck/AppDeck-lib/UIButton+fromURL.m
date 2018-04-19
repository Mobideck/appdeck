//
//  UIButton+fromURL.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 13/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "UIButton+fromURL.h"
#import "LogViewController.h"
#import "UIImage+Resize.h"
#import "AppDeck.h"
#import "AppURLCache.h"

@implementation UIButton (fromURL)

+(UIButton *)buttonFromURL:(NSURL *)url height:(CGFloat)height
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    void (^handler)(NSData *,NSURLResponse *,NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        if (error != nil || data == nil || image == nil)
        {
            [glLog error:@"Load image button '%@' failed: %@", url, (error != nil ? error : @"loading failed")];
            return;
        }
        image = [image retinaEnabledImageScaledToFitHeight:height];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    };
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AppDeck *app = [AppDeck sharedInstance];
    NSCachedURLResponse *cachedResponse = [app.cache getCacheResponseForRequest:request];
    if (cachedResponse)
        handler(cachedResponse.data, cachedResponse.response, nil);
    else
    
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: handler] resume];

       // [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handler];
    
    return button;
}


@end
