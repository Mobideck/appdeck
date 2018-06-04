//
//  ImageBanner.m
//  AppDeck
//
//  Created by hanine ben saad on 14/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "ImageBanner.h"
#import "UIImageView+WebCache.h"
#import <Masonry/Masonry.h>
#import "NSString+UIColor.h"

@interface BannerCell : UIView

@property (nonatomic,retain) UIImageView*imageView;
@property (nonatomic,retain) UILabel*titleLabel,*subtitleLabel;
@property (nonatomic,retain) NSDictionary*data;
@property (nonatomic,retain) UIView*container;


@end

@implementation BannerCell

static const CGFloat labelPadding = 10;

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    
    [self setup];
    return self;
}

-(void)setData:(NSDictionary *)data
{
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:data[@"image"]]
                  placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                      NSLog(@"error %@", error);
                  }];
    
    _titleLabel.text=data[@"title"];
    _subtitleLabel.text=data[@"subtitle"];
    
    CGSize captionLabelSize1 = [self sizeThatFits:self.bounds.size label:_titleLabel];
    _titleLabel.frame = CGRectMake(10,self.frame.size.height - captionLabelSize1.height,
                                   captionLabelSize1.width, captionLabelSize1.height);
    
    CGSize captionLabelSize2 = [self sizeThatFits:self.bounds.size label:_subtitleLabel];
    _subtitleLabel.frame = CGRectMake(10,self.frame.size.height - captionLabelSize2.height,
                                      captionLabelSize2.width, captionLabelSize2.height);
    
    float height= captionLabelSize1.height+captionLabelSize2.height;
    _container.frame=CGRectMake(8, self.frame.size.height-height-40, self.frame.size.width-16, height);
    
}

- (CGSize)sizeThatFits:(CGSize)size label:(UILabel*)label
{
    CGFloat maxHeight = 9999;
    if (label.numberOfLines > 0){
        maxHeight = label.font.leading*label.numberOfLines;
        CGSize textSize =[label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
        return CGSizeMake(size.width, textSize.height + labelPadding*label.numberOfLines );
    }
    
    return CGSizeZero;
}

-(void)setup
{
    
    _imageView=[[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode=UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    
    _container=[[UIView alloc]init];
    _container.backgroundColor=[UIColor colorWithWhite:1 alpha:0.4];
    
    _container.layer.cornerRadius=3;
    _container.layer.masksToBounds=true;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _titleLabel.opaque = NO;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;// UILineBreakModeWordWrap;
    _titleLabel.numberOfLines = 1;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.shadowColor = [UIColor blackColor];
    _titleLabel.shadowOffset = CGSizeMake(1, 1);
    _titleLabel.font = [UIFont systemFontOfSize:17];
    
    [_container addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_container.mas_left).with.offset(5);
        make.top.equalTo(_container.mas_top).with.offset(5);
        make.right.equalTo(_container.mas_right).with.offset(-5);
    }];
    
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _subtitleLabel.opaque = NO;
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;// UILineBreakModeWordWrap;
    _subtitleLabel.numberOfLines = 1;
    _subtitleLabel.textColor = [UIColor whiteColor];
    _subtitleLabel.shadowColor = [UIColor blackColor];
    _subtitleLabel.shadowOffset = CGSizeMake(1, 1);
    _subtitleLabel.font = [UIFont systemFontOfSize:14];
    
    [_container addSubview:_subtitleLabel];
    [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_container.mas_left).with.offset(5);
        make.top.equalTo(_titleLabel.mas_bottom).with.offset(5);
        make.right.equalTo(_container.mas_right).with.offset(-5);
    }];
    [self addSubview:_container];
    
}

    
@end

@interface ImageBanner ()
{
    NSMutableArray * ImagesDict;
    NSTimer*timer;
}

@end

@implementation ImageBanner

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame
{
    
    self=[super initWithFrame:frame];
    if (self)
    {
        
        ImagesDict=[NSMutableArray array];
       
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if(!_collectionView)
    {
        
        [self setupScrollerWithImages];
 
        _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, _scrollView.frame.size.height-30, self.frame.size.width, 30)];
        _pageControl.backgroundColor=[UIColor colorWithRed:30/255 green:30/255 blue:30/255 alpha:1];
        _pageControl.numberOfPages=[ImagesDict count];
        _pageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor=[UIColor whiteColor];
        _pageControl.currentPage=0;
        [self addSubview:_pageControl];
        
        if (ImagesDict.count==1)
        {
            _pageControl.alpha=0;
        }

    }
    
}

-(void)setupScrollerWithImages{
    _scrollView=[[UIScrollView alloc] initWithFrame:self.frame];

    _scrollView.backgroundColor=[UIColor colorWithRed:30/255 green:30/255 blue:30/255 alpha:1];
    _scrollView.delegate = self;
    float x = 0.0;
    float y = 0.0;
    float index = 0;
    self.scrollView.showsHorizontalScrollIndicator=YES;
    [self.scrollView setPagingEnabled:YES];
    self.scrollView.contentSize = CGSizeMake(ImagesDict.count*self.frame.size.width, self.frame.size.height);
    for (NSDictionary*dict in ImagesDict)
    {
        
        BannerCell* cell = [[BannerCell alloc]initWithFrame:CGRectMake(x, y, self.frame.size.width, self.frame.size.height)];
        
        cell.data=dict;
        [self.scrollView addSubview:cell];
        index = index + 1;
        x = self.scrollView.frame.size.width * index;
    }
    [self addSubview:_scrollView];
    
    if ([[ImagesDict[0] objectForKey:@"auto_scroll"] boolValue])
        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(autoscroll) userInfo:nil repeats:true];

}

-(void)autoscroll
{
    if ([[ImagesDict[0] objectForKey:@"auto_scroll"] boolValue])
    {
        float contentWidth = self.scrollView.contentSize.width;
        float x = self.scrollView.contentOffset.x + self.scrollView.frame.size.width;
        if (x < contentWidth)
        {
            [self.scrollView setContentOffset:CGPointMake(x, 0) animated:true];
        }
        else
        {
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:true];
        }
    }
}

-(void)addImage:(NSDictionary*)imageDict
{
    [ImagesDict addObject:imageDict];
    
    _pageControl.numberOfPages=[ImagesDict count];

    [_collectionView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int pageNum = (int)(self.scrollView.contentOffset.x / self.scrollView
                   .frame.size.width);
    _pageControl.currentPage = pageNum;
    
}
@end
