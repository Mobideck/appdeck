//
//  PageBarButtonItem.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 07/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKNumberBadgeView/MKNumberBadgeView.h"

@class LoaderChildViewController;

@interface PageBarButton : UIButton
{
//    UIButton *button;
    MKNumberBadgeView *badgeView;
}

@property (nonatomic, weak) LoaderChildViewController* child;

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *contentalt;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *iconalt;

@property (nonatomic, assign) int   badgeValue;

-(id)initWithInfos:(id)infos andChild:(LoaderChildViewController *)child;

@end
