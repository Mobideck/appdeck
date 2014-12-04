//
//  CRNavigationBar.m
//  CRNavigationControllerExample
//
//  Created by Corey Roberts on 9/24/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "CRNavigationBar.h"
#import <QuartzCore/QuartzCore.h>
#import "../IOSVersion.h"
#import "../AppDeck.h"

@interface CRNavigationBar ()
@property (nonatomic, strong) CALayer *colorLayer;
@end

@implementation CRNavigationBar

static CGFloat const kDefaultColorLayerOpacity = 0.5f;
static CGFloat const kSpaceToCoverStatusBars = 20.0f;

- (void)setBarTintColor:(UIColor *)barTintColor
{
    AppDeck *appDeck = [AppDeck sharedInstance];
    if (appDeck.iosVersion >= 7.0)
        [super setBarTintColor:barTintColor];

    if (self.colorLayer == nil)
    {
        self.colorLayer = [CALayer layer];
        self.colorLayer.opacity = kDefaultColorLayerOpacity;
        [self.layer addSublayer:self.colorLayer];
    }
    
    self.colorLayer.backgroundColor = barTintColor.CGColor;
}

- (void)setBarTintColor1:(UIColor *)color1 color2:(UIColor *)color2
{
    AppDeck *appDeck = [AppDeck sharedInstance];
    if (appDeck.iosVersion >= 7.0)
        [super setBarTintColor:color1];
        //        [super setBarTintColor:[color1 colorWithAlphaComponent:0.99]];
//        [super setBarTintColor:[color1 colorWithAlphaComponent:kDefaultColorLayerOpacity]];
        
    if (self.colorLayer == nil)
    {
        CAGradientLayer * bgGradientLayer = [CAGradientLayer layer];
        bgGradientLayer.frame = self.bounds;
        bgGradientLayer.colors = @[ (id)[color1 CGColor], (id)[color2 CGColor] ];
        self.colorLayer = bgGradientLayer;
        self.colorLayer.opacity = kDefaultColorLayerOpacity;
        [self.layer addSublayer:self.colorLayer];
    }
    
    self.colorLayer.backgroundColor = color1.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.colorLayer != nil) {
        self.colorLayer.frame = CGRectMake(0, 0 - kSpaceToCoverStatusBars, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + kSpaceToCoverStatusBars);
        
        [self.layer insertSublayer:self.colorLayer atIndex:1];
    }
}

- (void)displayColorLayer:(BOOL)display {
    self.colorLayer.hidden = !display;
}

@end
