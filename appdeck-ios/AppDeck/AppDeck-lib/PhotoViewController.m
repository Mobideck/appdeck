//
//  PhotoViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 16/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "PhotoViewController.h"
#import "AppDeck.h"
#import "AppURLCache.h"
#import "LogViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+zoomToPoint.h"

@interface PhotoViewController ()

@end

static const CGFloat labelPadding = 10;

@implementation PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

   
    scrollview = [[UIScrollView alloc] init];
    scrollview.minimumZoomScale = 0.05;
    scrollview.maximumZoomScale = 20;
    scrollview.showsHorizontalScrollIndicator = NO;
    scrollview.showsVerticalScrollIndicator = NO;
    scrollview.delegate = self;
    [self.view addSubview:scrollview];
/*    if (imageView == nil)
        imageView = [[UIImageView alloc] init];*/
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    //imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [scrollview addSubview:imageView];
    [self setupCaption];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(PhotoViewController *) photoViewWithUrl:(NSURL *)url thumbnail:(NSURL *)thumbnail caption:(NSString *)caption
{
    PhotoViewController *photoView = [[PhotoViewController alloc] init];
    photoView.url = url;
    photoView.urlThumbnail = thumbnail;
    photoView.caption = caption;
    return photoView;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat maxHeight = 9999;
    if (captionLabel.numberOfLines > 0){
        maxHeight = captionLabel.font.leading*captionLabel.numberOfLines;
        CGSize textSize =[captionLabel.text sizeWithAttributes:@{NSFontAttributeName:captionLabel.font}];
        
        
        // NSLog(@"sizee %f",textSize1.);
        
        return CGSizeMake(size.width, textSize.height + labelPadding * 2);
        
    }
    
    //    CGSize textSize = [captionLabel.text sizeWithFont:captionLabel.font
    //                              constrainedToSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
    //                                  lineBreakMode:captionLabel.lineBreakMode];
    
    return CGSizeZero;
}


- (void)setupCaption
{
    if (self.caption == nil || [self.caption isEqualToString:@""])
        return;
    captionLabel = [[UILabel alloc] init];
    captionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    captionLabel.opaque = NO;
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.textAlignment = NSTextAlignmentCenter;// UITextAlignmentCenter;
    captionLabel.lineBreakMode = NSLineBreakByWordWrapping;// UILineBreakModeWordWrap;
    captionLabel.numberOfLines = 3;
    captionLabel.textColor = [UIColor whiteColor];
    captionLabel.shadowColor = [UIColor blackColor];
    captionLabel.shadowOffset = CGSizeMake(1, 1);
    captionLabel.font = [UIFont systemFontOfSize:17];
    captionLabel.text = self.caption;
    
    captionContainer = [[UIView alloc] init];
    captionContainer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [captionContainer addSubview:captionLabel];
    [self.view addSubview:captionContainer];
}

/*-(void)isMain:(BOOL)isMain
{
    sharedManager

    
    if (isMain)
    [operation set
}*/

-(void)setState:(PhotoViewControllerState)state
{
    if (state == PhotoViewControllerStateBackground)
    {
        [self performSelector:@selector(unLoadImage) withObject:nil afterDelay:0.01];
    }
    else if (state == PhotoViewControllerStateNextScreen)
    {
        [self performSelector:@selector(loadImage) withObject:nil afterDelay:0.01];
    }
    else if (state == PhotoViewControllerStateOnScreen)
    {
        [self performSelector:@selector(loadImage) withObject:nil afterDelay:0.01];
    }
    currentState = state;
}


-(void)toggleZoom:(UITapGestureRecognizer *)sender;
{
    CGFloat fullScreenZoomScale = [self getFullScreenZoomScale];
    if (scrollview.zoomScale <= fullScreenZoomScale)
    {
        CGPoint location = [sender locationInView:scrollview];
        //[scrollview setZoomScale:4.0 animated:YES];
        [scrollview zoomToPoint:location withScale:fullScreenZoomScale*4 animated:YES];
    } else {
        [scrollview setZoomScale:fullScreenZoomScale animated:YES];
    }
}

-(void)unLoadImage
{
    if (imageLoaded == NO)
        return;
    imageLoaded = NO;
    //imageView.image = nil;
    [imageView removeFromSuperview];
//    [imageView cancelCurrentImageLoad];
    [imageView sd_cancelCurrentImageLoad];
    imageView = nil;
    
    imageWasSet = NO;
    [self viewWillLayoutSubviews];
}

- (UIImage*)getFinalProgressImage:(UIImage *)image placeholderImage:(UIImage *)placeholder
{
    /// error ?
    if (placeholder.size.height == 0 || image.size.height == 0)
        return image;
    
    // image ration should be almost equals
    //NSLog(@"%fx%f - %fx%f => %f", image.size.width, image.size.height, placeholder.size.width, placeholder.size.height, fabsf(image.size.width / image.size.height - placeholder.size.width / placeholder.size.height));
    if (fabs(image.size.width / image.size.height - placeholder.size.width / placeholder.size.height) > 0.2)
    {
        //NSLog(@"image and placeHolder are too different: %fx%f - %fx%f", image.size.width, image.size.height, placeholder.size.width, placeholder.size.height);
        return image;
    }
    
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // put scaled placeholder
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), placeholder.CGImage);
    CGContextRestoreGState(context);
    
    [image drawAtPoint:CGPointMake(0, 0)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(void)loadImage
{
    if (imageLoaded)
        return;
    imageLoaded = YES;
    
    UIImage *placeholderImage = nil;
    
    if (self.urlThumbnail != nil)
    {
        AppDeck *app = [AppDeck sharedInstance];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.urlThumbnail cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        NSCachedURLResponse *cachedResponse = [app.cache cachedResponseForRequest:request];
        if (cachedResponse)
        {
            placeholderImage = [UIImage imageWithData:cachedResponse.data];
        }
    }

    imageView = [[UIImageView alloc] init];
    //[imageView.layer setMinificationFilter:kCAFilterTrilinear];
    [scrollview addSubview:imageView];
    
/*
    __weak typeof(self) _self = self;
    __weak UIImageView *_imageView = imageView;
    
    [imageView setImageWithURL:self.url placeholderImage:placeholderImage options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        NSLog(@"Image is set : %fx%f in %@", _imageView.image.size.width, _imageView.image.size.height, _self);
        [_self viewWillLayoutSubviews];
    }];*/
    if (operation)
    {
        [operation cancel];
        operation = nil;
    }
    
/*    if (placeholderImage)
    {
        imageView.image = placeholderImage;
        [self viewWillLayoutSubviews];
//        imageWasSet = NO;
    }*/
    
    __block BOOL workInprogress = NO;
    __block BOOL workFinished = NO;
    __weak UIImageView *_imageView = imageView;
    __weak PhotoViewController *_self = self;
    
    operation = [SDWebImageManager.sharedManager downloadImageWithURL:self.url options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
       // _imageView.backgroundColor=[UIColor redColor];
        __strong UIImageView *sself = _imageView;
        if (!sself)
            return;
        
        if (image == nil)
            image = placeholderImage;
        else
            imageIsReady = YES;
        
        if (image && finished == NO && workInprogress == NO)
        {  
            workInprogress = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *tmpimage = [_self getFinalProgressImage:image placeholderImage:placeholderImage];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (workFinished == YES)
                    {
                        //NSLog(@"NOT put progress image: %@", self.url);
                    } else {
                        //NSLog(@"put progress image: %@", self.url);
                        sself.image = tmpimage;
                        [sself setNeedsLayout];
                        if (imageWasSet == NO)
                            [_self viewWillLayoutSubviews];
                        workInprogress = NO;
                    }
                });
            });
        }
        else if (image)
        {
            
            //                                                 dispatch_barrier_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            //                                                     dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"put final image: %@", self.url);
            sself.image = image;
            workFinished = YES;
            [sself setNeedsLayout];
            if (imageWasSet == NO)
                [_self viewWillLayoutSubviews];
            //                                                     });
            //                                                 });
        }else{
            NSLog(@"oooooo");
            
            
//            sself.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
//            workFinished = YES;
//            [sself setNeedsLayout];
//            if (imageWasSet == NO)
//                [_self viewWillLayoutSubviews];
        }

    }];
    
    /*
    operation = [SDWebImageManager.sharedManager downloadWithURL:self.url options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                                         {
                                             __strong UIImageView *sself = _imageView;
                                             if (!sself) return;
                                             
                                             if (image == nil)
                                                 image = placeholderImage;
                                             else
                                                 imageIsReady = YES;
                                             
                                             if (image && finished == NO && workInprogress == NO)
                                             {
                                                 workInprogress = YES;
                                                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                     UIImage *tmpimage = [_self getFinalProgressImage:image placeholderImage:placeholderImage];
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         if (workFinished == YES)
                                                         {
                                                              //NSLog(@"NOT put progress image: %@", self.url);
                                                         } else {
                                                             //NSLog(@"put progress image: %@", self.url);
                                                             sself.image = tmpimage;
                                                             [sself setNeedsLayout];
                                                             if (imageWasSet == NO)
                                                                 [_self viewWillLayoutSubviews];
                                                             workInprogress = NO;
                                                         }
                                                     });
                                                 });
                                             }
                                             else if (image)
                                             {

//                                                 dispatch_barrier_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         //NSLog(@"put final image: %@", self.url);
                                                         sself.image = image;
                                                         workFinished = YES;                                                 
                                                         [sself setNeedsLayout];
                                                         if (imageWasSet == NO)
                                                             [_self viewWillLayoutSubviews];
//                                                     });
//                                                 });
                                             }
                                         }];*/

}

-(UIImage *)image
{
    return imageView.image;
}

-(void)centerImage
{
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.view.bounds.size;
    CGRect frameToCenter = imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    imageView.frame = frameToCenter;
}

-(CGFloat)getFullScreenZoomScale
{
    CGFloat widthRatio = scrollview.frame.size.width / imageView.image.size.width;
    CGFloat heightRatio = scrollview.frame.size.height / imageView.image.size.height;
    CGFloat initialZoom = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    return initialZoom;
}

-(void)setFullScreen:(BOOL)fullScreen
{
    captionLabel.hidden = fullScreen;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    /*
    NSLog(@"AVANT");
    NSLog(@"PhotoViewController: view: %fx%f - %f~%f", self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    NSLog(@"PhotoViewController: scrollview: %fx%f - %f~%f", scrollview.frame.origin.x, scrollview.frame.origin.y, scrollview.frame.size.width, scrollview.frame.size.height);
    NSLog(@"PhotoViewController: imageview: %fx%f - %f~%f", imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
    NSLog(@"PhotoViewController: image: %fx%f", imageView.image.size.width, imageView.image.size.height);
    */
    BOOL rotate = scrollview.frame.size.width != self.view.bounds.size.width;
    CGFloat ratio = self.view.bounds.size.width / scrollview.frame.size.width;
    
    if (currentState == PhotoViewControllerStateOnScreen)
        NSLog(@"ROTATE: %d - RATIO: %f", rotate, ratio);
    
    scrollview.frame = self.view.bounds;
    
    if (imageView.image.size.width != 0 && imageView.image.size.height != 0)
    {
        
        //    scrollview.contentSize = self.view.bounds.size;
        //    imageView.frame = CGRectMake(0, 0, scrollview.contentSize.width, scrollview.contentSize.height);
        
/*        if (self.view.bounds.size.width > self.view.bounds.size.height)
            scrollview.contentSize = CGSizeMake(imageView.image.size.width, imageView.image.size.height);
        else
            scrollview.contentSize = CGSizeMake(imageView.image.size.height, imageView.image.size.width);*/
        
        
        //NSLog(@"PhotoViewController: imageview: %fx%f - %f~%f", imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);

        //NSLog(@"PhotoViewController: imageview: %fx%f - %f~%f", imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
        
        if (imageIsReady == YES && imageWasSet == NO && imageView.image.size.width != 0 && imageView.image.size.height != 0)
        {
            imageView.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
            scrollview.contentSize = CGSizeMake(imageView.image.size.width, imageView.image.size.height);            
            [scrollview zoomToRect:imageView.frame animated:NO];
            /*
             scrollview.zoomScale = 0.15;//[self getFullScreenZoomScale];
            imageView.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);*/
            imageWasSet = YES;
            //NSLog(@"zoomScale: %f", scrollview.zoomScale/*, initialZoom*/);
        }

        [self centerImage];
     
        scrollview.minimumZoomScale = [self getFullScreenZoomScale];
        scrollview.maximumZoomScale = [self getFullScreenZoomScale] * 8;
        
        if (rotate)
            [scrollview setZoomScale:scrollview.zoomScale*ratio animated:NO];
        
    }
    /*    if (rotate)
    {
        NSLog(@"rotate !");
        scrollview.zoomScale = [self getFullScreenZoomScale];
    }*/
    //NSLog(@"PhotoViewController: imageview: %fx%f - %f~%f", imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
    //if (imageWasSet == NO)
    //    return;
    

    


    
    CGSize captionLabelSize = [self sizeThatFits:self.view.bounds.size];
    CGSize captionContainerSize = CGSizeMake(self.view.frame.size.width, captionLabelSize.height + 2 * labelPadding);
    
    captionContainer.frame = CGRectMake(0, self.view.bounds.size.height - captionContainerSize.height, captionContainerSize.width, captionContainerSize.height);
    captionLabel.frame = CGRectMake(captionContainerSize.width / 2 - captionLabelSize.width / 2,
                                    captionContainerSize.height / 2 - captionLabelSize.height / 2,
                                    captionLabelSize.width, captionLabelSize.height);
    
/*
    NSLog(@"APRES");
    NSLog(@"PhotoViewController: view: %fx%f - %f~%f", self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    NSLog(@"PhotoViewController: scrollview: %fx%f - %f~%f", scrollview.frame.origin.x, scrollview.frame.origin.y, scrollview.frame.size.width, scrollview.frame.size.height);
    NSLog(@"PhotoViewController: imageview: %fx%f - %f~%f", imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
    NSLog(@"PhotoViewController: image: %fx%f", imageView.image.size.width, imageView.image.size.height);
  */  
/*    NSLog(@"Photo: view: %fx%f - %f~%f", self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    NSLog(@"Photo: scrollview: %fx%f - %f~%f", scrollview.frame.origin.x, scrollview.frame.origin.y, scrollview.frame.size.width, scrollview.frame.size.height);
    NSLog(@"Photo: imageViewThumbnail: %fx%f - %f~%f", imageViewThumbnail.frame.origin.x, imageViewThumbnail.frame.origin.y, imageViewThumbnail.frame.size.width, imageViewThumbnail.frame.size.height);*/
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"zoomscale: %f", scrollView.zoomScale);
    [self centerImage];
}

@end
