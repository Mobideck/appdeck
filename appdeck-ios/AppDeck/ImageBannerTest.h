//
//  ImageBannerTest.h
//  AppDeck
//
//  Created by hanine ben saad on 25/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"


@interface ImageBannerTest : UIView<iCarouselDelegate,iCarouselDataSource>{
    NSArray*array;
}

@property (nonatomic, strong) IBOutlet iCarousel *carousel;

@end
