//
//  GradientView.m
//  AppDeck
//
//  Created by hanine ben saad on 25/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView


-(void)setGradientViewWithcolors:(NSArray*)colors{
    gradient=[[CAGradientLayer alloc] init];
    gradient.frame = self.bounds;
    gradient.colors = colors;
    [self.layer insertSublayer:gradient atIndex:0];
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    gradient.frame=self.bounds;
}

@end
