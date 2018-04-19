//
//  PhotoBrowserViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 16/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoaderChildViewController.h"

@class PageBarButton;

@interface PhotoBrowserViewController : LoaderChildViewController <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    
    PageBarButton *buttonRefresh;
    PageBarButton *buttonCancel;
    PageBarButton *buttonPrevious;
    PageBarButton *buttonNext;
    PageBarButton *buttonAction;
    
    NSTimer *controlVisibilityTimer;
    BOOL    areControlsHidden;
    
    UITapGestureRecognizer *tapRecognizer;
    UITapGestureRecognizer *doubleTapRecognizer;
    
   // UIActionSheet *actionSheet;
    
    NSInteger currentIndex;
}

@property (strong, nonatomic) NSMutableArray *photos;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) NSInteger startingIndex;

@property (strong, nonatomic) UIColor *bgColor;

+(PhotoBrowserViewController *)photoBrowserWithConfig:(NSDictionary *)config baseURL:(NSURL *)baseUrl error:(NSError **)error;

@end
