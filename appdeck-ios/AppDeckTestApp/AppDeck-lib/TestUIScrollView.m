//
//  TestUIScrollView.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 19/10/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "TestUIScrollView.h"

@implementation TestUIScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setContentOffset:(CGPoint)contentOffset
{
    if (contentOffset.x == 0 && contentOffset.y == 0)
        return;
    [super setContentOffset:contentOffset];
}

-(void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [super setContentOffset:contentOffset animated:animated];
}


-(void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
    
}

-(void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
}
@end
