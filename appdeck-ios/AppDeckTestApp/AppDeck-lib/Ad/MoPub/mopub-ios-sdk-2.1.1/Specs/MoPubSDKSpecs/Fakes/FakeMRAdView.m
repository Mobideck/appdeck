//
//  FakeMRAdView.m
//  MoPubSDK
//
//  Created by Yuan Ren on 10/16/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMRAdView.h"

@interface MRAdView ()

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

@end

@implementation FakeMRAdView

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    self.currentInterfaceOrientation = newOrientation;
    
    [super rotateToOrientation:newOrientation];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    self.loadedHTMLString = string;
    
    [super loadHTMLString:string baseURL:baseURL];
}

@end
