//
//  NAAdPlacement.h
//  Oxom
//
//  Created by Sébastien Sans on 24/03/2015.
//  Copyright (c) 2015 NetAvenir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NAAdTypes.h"

@interface NAAdPlacement : NSObject

#pragma mark Public methods

- (instancetype)initWithPlacementIdentifier:(NSString *)placementIdentifier;
- (void)presentInterstitialForViewController:(UIViewController *)viewController;
- (void)presentBannerForViewController:(UIViewController *)viewController withPosition:(NAAdPosition)position;
- (void)presentBannerForViewController:(UIViewController *)viewController withPosition:(NAAdPosition)position withTopMargin:(CGFloat)topMargin;
- (void)presentBannerForViewController:(UIViewController *)viewController withPosition:(NAAdPosition)position withBottomMargin:(CGFloat)bottomMargin;
- (void)presentBannerForViewController:(UIViewController *)viewController withPosition:(NAAdPosition)position withTopMargin:(CGFloat)topMargin withBottomMargin:(CGFloat)bottomMargin;

@property (nonatomic, weak) id<NAAdPlacementDelegate> delegate;

@end
