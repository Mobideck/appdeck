//
//  ImagePreload.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 20/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "ImagePreload.h"
#import "AppURLCache.h"
#import "AppDeck.h"
#import "LoaderViewController.h"
#import "UIImage+Resize.h"

@implementation ImagePreload

-(id)initWithURL:(NSURL *)img_url height:(CGFloat)img_height
{
    self = [super init];
    if (self)
    {
        self.url = img_url;
        self.height = img_height;
    }
    return self;
}

-(void)preload
{
    __block AppDeck *app = [AppDeck sharedInstance];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
 __block ImagePreload *me = self;
//        NSURLResponse *response;
//        NSError *error;
       __block NSData *data = nil;
        NSCachedURLResponse *cacheResponse = [app.cache cachedResponseForRequest:[NSURLRequest requestWithURL:me.url]];
        
        if (cacheResponse){
            data = cacheResponse.data;

        }
        else
           // data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:self.url] returningResponse:&response error:&error];
        {
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:self.url]
                                                    completionHandler:
                                          ^(NSData *dataa, NSURLResponse *response, NSError *error) {
                                              
                                             // dispatch_async(dispatch_get_main_queue(), ^{
                                                 data=dataa;
                                                  
                                                  dispatch_semaphore_signal(semaphore);

                                                  // Your code to run on the main queue/thread
                                           //   });
                                              
                                          }];
            
            [task resume];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

            
        }
        
        UIImage *tmp = [UIImage imageWithData:data];
        if (tmp == nil)
        me.internal_image = [[UIImage alloc] init];
        else
        me.internal_image = [tmp retinaEnabledImageScaledToFitHeight:self.height];
        
        
        

        
    });
}



-(UIImage *)image
{
    while (_internal_image == nil)
    {
        usleep(0.0001);
    }
    return _internal_image;
}

@end
