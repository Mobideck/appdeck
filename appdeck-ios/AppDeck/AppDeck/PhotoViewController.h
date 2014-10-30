//
//  PhotoViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 16/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImage/UIImageView+WebCache.h"

typedef enum {
    PhotoViewControllerStateBackground,
    PhotoViewControllerStateNextScreen,
    PhotoViewControllerStateOnScreen
} PhotoViewControllerState;

@interface PhotoViewController : UIViewController <UIScrollViewDelegate>
{
    UIScrollView *scrollview;    
    UIImageView *imageView;
    UILabel *captionLabel;
    UIView *captionContainer;
    BOOL imageLoaded;
    id<SDWebImageOperation> operation;
    BOOL imageIsReady;
    BOOL imageWasSet;
    
    PhotoViewControllerState currentState;
}

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURL *urlThumbnail;
@property (strong, nonatomic) NSString *caption;

-(UIImage *)image;

+(PhotoViewController *) photoViewWithUrl:(NSURL *)url thumbnail:(NSURL *)thumbnail caption:(NSString *)caption;

-(void)loadImage;

-(void)toggleZoom:(UITapGestureRecognizer *)sender;

-(void)setState:(PhotoViewControllerState)state;

-(void)setFullScreen:(BOOL)fullScreen;

@end
