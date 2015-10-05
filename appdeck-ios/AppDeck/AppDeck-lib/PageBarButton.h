//
//  PageBarButtonItem.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 07/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView/JSBadgeView.h"

@class LoaderChildViewController;

@interface PageBarButton : UIButton
{
//    UIButton *button;
    JSBadgeView *badgeView;
}

@property (nonatomic, weak) LoaderChildViewController* child;

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *contentalt;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *iconalt;

@property (nonatomic, assign) NSString *badgeValue;

-(id)initWithInfos:(id)infos andChild:(LoaderChildViewController *)child;

@end
