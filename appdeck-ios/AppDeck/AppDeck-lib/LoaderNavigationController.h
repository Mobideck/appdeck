//
//  LoaderNavigationController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 07/01/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoaderViewController;

@interface LoaderNavigationController : UINavigationController<UINavigationControllerDelegate>

@property (weak, nonatomic) LoaderViewController *loader;

@property (nonatomic, assign) BOOL  isAnimating;

//@property (nonatomic,copy) dispatch_block_t completionBlock;

//@property (nonatomic, strong) NSMutableArray *completionBlocks;

@end
