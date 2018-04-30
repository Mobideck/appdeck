//
//  MyCollectionViewController.h
//  AppDeck
//
//  Created by hanine ben saad on 27/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoaderChildViewController.h"

@interface MyCollectionViewController : LoaderChildViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic, retain) UICollectionView*collection;

@property (nonatomic, strong) AppDeckApiCall *origin;

@end
