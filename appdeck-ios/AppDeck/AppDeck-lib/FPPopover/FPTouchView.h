//
//  FPTouchView.h
//
//  Created by Alvise Susmel on 4/16/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//
//  https://github.com/50pixels/FPPopover

#import <UIKit/UIKit.h>

typedef void (^FPTouchedOutsideBlock)(void);
typedef void (^FPTouchedInsideBlock)(void);

@interface FPTouchView : UIView
{
    __strong FPTouchedOutsideBlock _outsideBlock;
    __strong FPTouchedInsideBlock  _insideBlock;
}

-(void)setTouchedOutsideBlock:(FPTouchedOutsideBlock)outsideBlock;

-(void)setTouchedInsideBlock:(FPTouchedInsideBlock)insideBlock;

@end
