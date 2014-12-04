//
//  UIImageView+fromURL.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 13/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "UIImageView+fromURL.h"
#import "LogViewController.h"
#import "AppDeck.h"
#import "AppURLCache.h"
#import "UIImage+Resize.h"

@implementation UIImageView (fromURL)

+(UIImageView *)imageViewFromURL:(NSURL *)myUrl height:(CGFloat)height
{
    __block NSURL *url = myUrl;
    __block UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        __block UIImage *image = [UIImage imageWithData:data];
        if (error != nil || data == nil || image == nil)
        {
            [glLog error:@"load image '%@' failed: %@", url.relativeString, (error != nil ? error : @"not an image")];
            return;
        }
        image = [image retinaEnabledImageScaledToFitHeight:height];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            imageView.image = image;
            [imageView.superview setNeedsLayout];
        });
    };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AppDeck *app = [AppDeck sharedInstance];
        NSCachedURLResponse *cachedResponse = [app.cache getCacheResponseForRequest:request];
        if (cachedResponse)
            handler(cachedResponse.response, cachedResponse.data, nil);
        else
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handler];
    });
    

    return imageView;
}

+(UIImageView *)imageViewFromURL:(NSURL *)url width:(CGFloat)width
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        if (error != nil || data == nil || image == nil)
        {
            [glLog error:@"load image '%@' failed: %@", url.relativeString, (error != nil ? error : @"not an image")];
            return;
        }
        CGFloat height = width * image.size.height / image.size.width;
        image = [image retinaEnabledImageScaledToFitHeight:height];
        imageView.image = image;
        CGRect frame = imageView.frame;
        frame.size.width = width;
        frame.size.height = height;
        imageView.frame = frame;
        [imageView.superview setNeedsLayout];
    };
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AppDeck *app = [AppDeck sharedInstance];
    NSCachedURLResponse *cachedResponse = [app.cache getCacheResponseForRequest:request];
    if (cachedResponse)
        handler(cachedResponse.response, cachedResponse.data, nil);
    else
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handler];
    
    return imageView;
}

@end
