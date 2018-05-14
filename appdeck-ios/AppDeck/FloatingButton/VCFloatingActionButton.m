//
//  VCFloatingActionButton.m
//  starttrial
//
//  Created by Giridhar on 25/03/15.
//  Copyright (c) 2015 Giridhar. All rights reserved.
//

#import "VCFloatingActionButton.h"
#import "floatTableViewCell.h"
#import "LoaderConfiguration.h"
#import "AppURLCache.h"
#import "AppDeckApiCall.h"

#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

CGFloat animationTime = 0.55;
CGFloat rowHeight = 60.f;
NSInteger noOfRows = 0;
NSInteger tappedRow;
CGFloat previousOffset;
CGFloat buttonToScreenHeight;


@implementation VCFloatingActionButton

//@synthesize windowView;
//@synthesize hideWhileScrolling;
@synthesize delegate;

@synthesize bgScroller;

-(id)initWithFrame:(CGRect)frame normalImage:(UIImage*)passiveImage andPressedImage:(UIImage*)activeImage withScrollview:(UIScrollView*)scrView
{
    self = [super initWithFrame:frame];
    if (self)
    {
//        windowView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
//        _mainWindow = [UIApplication sharedApplication].keyWindow;
        _buttonView = [[UIView alloc]initWithFrame:frame];
        _buttonView.backgroundColor = [UIColor clearColor];
        _buttonView.userInteractionEnabled = YES;

        buttonToScreenHeight = SCREEN_HEIGHT - CGRectGetMaxY(self.frame);
        
        _menuTable = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/4, 0, 0.75*SCREEN_WIDTH,SCREEN_HEIGHT - (SCREEN_HEIGHT - CGRectGetMaxY(self.frame)) )];
        _menuTable.scrollEnabled = NO;
        
        _menuTable.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, CGRectGetHeight(frame))];
        
        _menuTable.delegate = self;
        _menuTable.dataSource = self;
        _menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuTable.backgroundColor = [UIColor clearColor];
        _menuTable.transform = CGAffineTransformMakeRotation(-M_PI); //Rotate the table
        
        previousOffset = scrView.contentOffset.y;
        
        bgScroller = scrView;

        _pressedImage = activeImage;
        _normalImage = passiveImage;
        [self setupButton];
        
    }
    return self;
}

-(void)setHideWhileScrolling:(BOOL)hideWhileScrolling
{
    if (bgScroller!=nil)
    {
        _hideWhileScrolling = hideWhileScrolling;
        if (hideWhileScrolling)
        {
            [bgScroller addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

-(void) setupButton
{
    _isMenuVisible = false;
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *buttonTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:buttonTap];
    
    UITapGestureRecognizer *buttonTap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    [_buttonView addGestureRecognizer:buttonTap3];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    UIVisualEffectView *vsview = [[UIVisualEffectView alloc]initWithEffect:nil];
    
    _bgView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
   // _bgView.alpha = 0;
    _bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *buttonTap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];

    buttonTap2.cancelsTouchesInView = NO;
    vsview.frame = _bgView.bounds;
  //  _bgView = vsview;
    [_bgView addGestureRecognizer:buttonTap2];
    
    _normalImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    _normalImageView.userInteractionEnabled = YES;
    _normalImageView.contentMode = UIViewContentModeScaleAspectFit;
    _normalImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _normalImageView.layer.shadowRadius = 5.f;
    _normalImageView.layer.shadowOffset = CGSizeMake(-10, -10);

    _pressedImageView  = [[UIImageView alloc]initWithFrame:self.bounds];
    _pressedImageView.contentMode = UIViewContentModeScaleAspectFit;
    _pressedImageView.userInteractionEnabled = YES;
    
    _normalImageView.image = _normalImage;
    _pressedImageView.image = _pressedImage;
   
    //crash fixed iOS11 - [_bgView addSubview:_menuTable];
   // [[(UIVisualEffectView *)_bgView contentView] addSubview:_menuTable];
    [_bgView addSubview:_menuTable];

    [_buttonView addSubview:_pressedImageView];
    [_buttonView addSubview:_normalImageView];
    [self addSubview:_normalImageView];

}

-(void)handleTap:(id)sender //Show Menu
{

    if (_isMenuVisible)
    {
        
        [self dismissMenu:nil];
    }
    else
    {
        [self.child.view addSubview:_bgView];
        [self.child.view addSubview:_buttonView];
        
      //  [_mainWindow addSubview:windowView];
        [self showMenu:nil];
    }
    _isMenuVisible  = !_isMenuVisible;
    
}

#pragma mark -- Animations
#pragma mark ---- button tap Animations

-(void) showMenu:(id)sender
{
    
    self.pressedImageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.pressedImageView.alpha = 0.0; //0.3
    [UIView animateWithDuration:animationTime/2 animations:^
     {
         self.bgView.alpha = 1;
         
         self.normalImageView.transform = CGAffineTransformMakeRotation(-M_PI);
         self.normalImageView.alpha = 0.0; //0.7

         self.pressedImageView.transform = CGAffineTransformIdentity;
         self.pressedImageView.alpha = 1;
         noOfRows = _buttonsArray.count;
         [_menuTable reloadData];

     }
         completion:^(BOOL finished)
     {
     }];

}

-(void) dismissMenu:(id) sender

{
    [UIView animateWithDuration:animationTime/2 animations:^
     {
         self.bgView.alpha = 0;
         self.pressedImageView.alpha = 0.f;
         self.pressedImageView.transform = CGAffineTransformMakeRotation(-M_PI);
         self.normalImageView.transform = CGAffineTransformMakeRotation(0);
         self.normalImageView.alpha = 1.f;
     } completion:^(BOOL finished)
     {
         noOfRows = 0;
         [_bgView removeFromSuperview];
         
//         [windowView removeFromSuperview];
//         [_mainWindow removeFromSuperview];
         
     }];
}

#pragma mark ---- Scroll animations

-(void) showMenuDuringScroll:(BOOL) shouldShow
{
    if (_hideWhileScrolling)
    {
        
        if (!shouldShow)
        {
            [UIView animateWithDuration:animationTime animations:^
             {
                 self.transform = CGAffineTransformMakeTranslation(0, buttonToScreenHeight*6);
             } completion:nil];
        }
        else
        {
            [UIView animateWithDuration:animationTime/2 animations:^
             {
                 self.transform = CGAffineTransformIdentity;
             } completion:nil];
        }
        
    }
}


-(void) addRows
{
    NSMutableArray *ip = [[NSMutableArray alloc]init];
    for (int i = 0; i< noOfRows; i++)
    {
        [ip addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [_menuTable insertRowsAtIndexPaths:ip withRowAnimation:UITableViewRowAnimationFade];
}




#pragma mark -- Observer for scrolling
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        
        NSLog(@"%f",bgScroller.contentOffset.y);
       
        CGFloat diff = previousOffset - bgScroller.contentOffset.y;
        
        if (ABS(diff) > 15)
        {
            if (bgScroller.contentOffset.y > 0)
            {
                [self showMenuDuringScroll:(previousOffset > bgScroller.contentOffset.y)];
                previousOffset = bgScroller.contentOffset.y;
            }
            else
            {
                [self showMenuDuringScroll:YES];
            }
            
        }

    }
}


#pragma mark -- Tableview methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return noOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(floatTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    double delay = (indexPath.row*indexPath.row) * 0.004;  //Quadratic time function for progressive delay

    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.95, 0.95);
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0,-(indexPath.row+1)*CGRectGetHeight(cell.imgView.frame));
    cell.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
    cell.alpha = 0.f;
    
    [UIView animateWithDuration:animationTime/2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        
        cell.transform = CGAffineTransformIdentity;
        cell.alpha = 1.f;
        
    } completion:^(BOOL finished)
    {
        
    }];
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"cell";
    floatTableViewCell *cell = [_menuTable dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        [_menuTable registerNib:[UINib nibWithNibName:@"floatTableViewCell" bundle:nil]forCellReuseIdentifier:identifier];
        cell = [_menuTable dequeueReusableCellWithIdentifier:identifier];
    }
    
    NSString*icon=[[_buttonsArray objectAtIndex:indexPath.row] objectForKey:@"icon"];
    
    if ([icon hasPrefix:@"!"])
    {
        UIImage *iconImage = self.child.loader.conf.icon_action.image;
        if ([icon isEqualToString:@"!action"])
            iconImage = self.child.loader.conf.icon_action.image;
        if ([icon isEqualToString:@"!ok"])
            iconImage = self.child.loader.conf.icon_ok.image;
        if ([icon isEqualToString:@"!cancel"])
            iconImage = self.child.loader.conf.icon_cancel.image;
        if ([icon isEqualToString:@"!close"])
            iconImage = self.child.loader.conf.icon_close.image;
        if ([icon isEqualToString:@"!config"])
            iconImage = self.child.loader.conf.icon_config.image;
        if ([icon isEqualToString:@"!info"])
            iconImage = self.child.loader.conf.icon_info.image;
        if ([icon isEqualToString:@"!menu"])
            iconImage = self.child.loader.conf.icon_menu.image;
        if ([icon isEqualToString:@"!next"])
            iconImage = self.child.loader.conf.icon_next.image;
        if ([icon isEqualToString:@"!previous"])
            iconImage = self.child.loader.conf.icon_previous.image;
        if ([icon isEqualToString:@"!refresh"])
            iconImage = self.child.loader.conf.icon_refresh.image;
        if ([icon isEqualToString:@"!search"])
            iconImage = self.child.loader.conf.icon_search.image;
        if ([icon isEqualToString:@"!up"])
            iconImage = self.child.loader.conf.icon_up.image;
        if ([icon isEqualToString:@"!down"])
            iconImage = self.child.loader.conf.icon_down.image;
        if ([icon isEqualToString:@"!user"])
            iconImage = self.child.loader.conf.icon_user.image;
        
        cell.imgView.image = iconImage;

    }else if (icon)
        [self downloadImage:icon forCell:cell];
    
    cell.title.text= [[_buttonsArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    return cell;
}

-(void)downloadImage:(NSString *)url forCell:(floatTableViewCell*)cell
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url relativeToURL:self.child.url]];
    
    NSCachedURLResponse *cachedResponse = [self.child.loader.appDeck.cache getCacheResponseForRequest:request];
    
    if (cachedResponse)
    {
       // [self setImageFromData:cachedResponse.data forState:state];
    }
    else
    {
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          if (error == nil)
                                          {
                                              dispatch_async(dispatch_get_main_queue(), ^
                                                             {
                                                                 cell.imgView.image = [UIImage imageWithData:data];
                                                             });
                                          }
                                          else
                                              NSLog(@"Failed to download icon: %@: %@", url, error);
                                      }];
        
        [task resume];
        
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"selected CEll: %tu",indexPath.row);
    [delegate didSelectMenuOptionAtIndex:indexPath.row];
//    [self removeFromSuperview];

    
    
    [UIView animateWithDuration:animationTime/2 animations:^
     {
         self.bgView.alpha = 0;
         self.pressedImageView.alpha = 0.f;
         self.pressedImageView.transform = CGAffineTransformMakeRotation(-M_PI);
         self.normalImageView.transform = CGAffineTransformMakeRotation(0);
         self.normalImageView.alpha = 1.f;
     } completion:^(BOOL finished)
     {
         noOfRows = 0;
         [_bgView removeFromSuperview];
         
         [self.child load:[[_buttonsArray objectAtIndex:indexPath.row] objectForKey:@"content"]];
         
         //         [windowView removeFromSuperview];
         //         [_mainWindow removeFromSuperview];
         
     }];
    
    
    
//    [self.child load:[[_buttonsArray objectAtIndex:indexPath.row] objectForKey:@"content"]];
    //[self dismissMenu:nil];

//     [_call sendCallbackWithResult:@[[[_buttonsArray objectAtIndex:indexPath.row] objectForKey:@"content"]]];
//     [_call performSelectorOnMainThread:@selector(sendCallbackWithResult:) withObject:[[_buttonsArray objectAtIndex:indexPath.row] objectForKey:@"content"] waitUntilDone:NO];
    
}

@end
