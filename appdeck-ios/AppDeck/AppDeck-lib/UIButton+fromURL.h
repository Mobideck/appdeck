//
//  UIButton+fromURL.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 13/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (fromURL)

+(UIButton *)buttonFromURL:(NSURL *)url height:(CGFloat)height;

@end
