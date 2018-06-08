//
//  myView.m
//  AppDeck
//
//  Created by hanine ben saad on 07/06/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "myView.h"
#import "LoaderChildViewController.h"
#import "AppURLCache.h"

@implementation myView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)downloadImage:(NSString *)url inChild:(LoaderChildViewController*)child
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url relativeToURL:child.url]];
    
    NSCachedURLResponse *cachedResponse = [child.loader.appDeck.cache getCacheResponseForRequest:request];
    
    if (cachedResponse)
    {
        // [self setImageFromData:cachedResponse.data forState:state];
    }
    else
    {
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                  {
                      if (error == nil)
                      {
                          dispatch_async(dispatch_get_main_queue(), ^
                                         {
                                             _imageView.image = [UIImage imageWithData:data];
                                         });
                      }
                      else
                          NSLog(@"Failed to download icon: %@: %@", url, error);
                  }];
        
        [task resume];
        
    }
}

@end
