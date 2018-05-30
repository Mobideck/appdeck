//
//  ImageBanner.h
//  AppDeck
//
//  Created by hanine ben saad on 14/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageBanner : UIView <UIScrollViewDelegate>

@property(nonatomic,retain) UICollectionView*collectionView;
@property(nonatomic,retain) UIScrollView*scrollView;
@property(nonatomic,retain) UIPageControl*pageControl;

@property(nonatomic,assign) float height;
-(void)addImage:(NSDictionary*)imageDict;

@end
