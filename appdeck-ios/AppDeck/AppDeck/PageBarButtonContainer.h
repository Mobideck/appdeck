//
//  PageBarButtonContainer.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoaderChildViewController;
@class PageBarButton;

@interface PageBarButtonContainer : UIView
{
    NSMutableArray *buttons;
    
    LoaderChildViewController *child;
}

-(long)count;

-(PageBarButton *)addButton:(id)infos;

- (id)initWithChild:(LoaderChildViewController *)_child;

@end
