//
//  ImagePreload.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 20/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagePreload : NSObject
{


}

@property (atomic, strong)              UIImage *internal_image;
@property (atomic, strong, readonly)    UIImage *image;
@property (atomic, strong)              NSURL   *url;
@property (atomic, assign)              CGFloat   height;

-(id)initWithURL:(NSURL *)url height:(CGFloat)height;

-(void)preload;

@end
