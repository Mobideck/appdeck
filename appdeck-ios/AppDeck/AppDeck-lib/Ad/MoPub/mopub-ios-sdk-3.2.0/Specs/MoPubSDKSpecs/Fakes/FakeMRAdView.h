//
//  FakeMRAdView.h
//  MoPubSDK
//
//  Created by Yuan Ren on 10/16/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MRAdView.h"

@interface FakeMRAdView : MRAdView

@property (nonatomic, assign) UIInterfaceOrientation currentInterfaceOrientation;
@property (nonatomic, copy) NSString *loadedHTMLString;

@end
