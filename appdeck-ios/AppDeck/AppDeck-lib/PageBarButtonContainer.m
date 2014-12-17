//
//  PageBarButtonContainer.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "PageBarButtonContainer.h"
#import "PageBarButton.h"

@implementation PageBarButtonContainer

- (id)initWithChild:(LoaderChildViewController *)_child
{
    self = [super initWithFrame:CGRectMake(0, 0, 0, 44)];
    if (self) {
        // Initialization code
        buttons = [[NSMutableArray alloc] init];
        child = _child;
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

-(long)count
{
    return buttons.count;
}

-(PageBarButton *)addButton:(id)infos
{
    PageBarButton *button = [[PageBarButton alloc] initWithInfos:infos andChild:child];
    
    if (button)
    {
        [buttons addObject:button];
        [self addSubview:button];
    }
    return button;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat x = 0;
    
    for (PageBarButton *button in buttons) {
        CGRect frame = button.frame;
        frame.origin.x = x;
        button.frame = frame;
        x += button.frame.size.width;
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, x, self.frame.size.height);
    [self.superview layoutSubviews];
}

@end
