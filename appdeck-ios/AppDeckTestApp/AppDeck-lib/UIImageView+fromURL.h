//
//  UIImageView+fromURL.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 13/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (fromURL)

+(UIImageView *)imageViewFromURL:(NSURL *)url height:(CGFloat)height;
+(UIImageView *)imageViewFromURL:(NSURL *)url width:(CGFloat)width;

@end
