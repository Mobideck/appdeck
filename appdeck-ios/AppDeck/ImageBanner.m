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

@interface BannerCell : UICollectionViewCell

@property (nonatomic,retain) UIImageView*imageView;
@property (nonatomic,retain) UILabel*titleLabel,*subtitleLabel;
@property (nonatomic,retain) NSDictionary*data;
@property (nonatomic,retain) UIView*container;
@property (nonatomic,retain) UIButton*previousBtn;
@property (nonatomic,retain) UIButton*nextBtn;

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
    _container.frame=CGRectMake(0, self.frame.size.height-height, self.frame.size.width, height);
    
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

-(void)layoutSubviews
{
    
}

-(void)setup
{
    
    _imageView=[[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode=UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    
    _container=[[UIView alloc]init];
    _container.backgroundColor=[UIColor colorWithWhite:1 alpha:0.2];
    
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
    
    _previousBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _previousBtn.backgroundColor=[UIColor colorWithWhite:1 alpha:0.6];
    [_previousBtn setImage:[UIImage imageNamed:@"previous"] forState:UIControlStateNormal];
    
//    UIBezierPath *maskPath = [UIBezierPath
//                              bezierPathWithRoundedRect:_previousBtn.bounds
//                              byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight)
//                              cornerRadii:CGSizeMake(5, 5)
//                              ];
//
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//
//    maskLayer.frame = self.bounds;
//    maskLayer.path = maskPath.CGPath;
//
//    _previousBtn.layer.mask = maskLayer;
    
    [self addSubview:_previousBtn];
    [_previousBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.centerY.equalTo(self.mas_centerY );
        make.width.equalTo(@40);
        make.height.equalTo(@50);
    }];

    _nextBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn.backgroundColor=[UIColor colorWithWhite:1 alpha:0.6];
    [_nextBtn setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [self addSubview:_nextBtn];
    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.centerY.equalTo(self.mas_centerY );
        make.width.equalTo(@40);
        make.height.equalTo(@50);
    }];
    
//    UIBezierPath *maskPath1 = [UIBezierPath
//                              bezierPathWithRoundedRect:_nextBtn.bounds
//                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
//                              cornerRadii:CGSizeMake(5, 5)
//                              ];
//    
//    CAShapeLayer *maskLayer1 = [CAShapeLayer layer];
//    
//    maskLayer1.frame = self.bounds;
//    maskLayer1.path = maskPath1.CGPath;
//    
//    _nextBtn.layer.mask = maskLayer1;
//   
}
    
@end

@interface ImageBanner ()
{
    NSMutableArray * ImagesDict;
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
        
        UICollectionViewFlowLayout *layout= [UICollectionViewFlowLayout new]; // standard flow layout
        
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.minimumLineSpacing=0;
        layout.minimumInteritemSpacing=0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        NSLog(@"%@",CGRectCreateDictionaryRepresentation(self.bounds));
        _collectionView.backgroundColor=[UIColor blackColor];
        [_collectionView setPagingEnabled:true];
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
        
        [_collectionView registerClass:[BannerCell class] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:_collectionView];
        
        _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, _collectionView.frame.size.height-30, self.frame.size.width, 30)];
        _pageControl.numberOfPages=[ImagesDict count];
        _pageControl.tintColor=[UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor=[UIColor whiteColor];
        _pageControl.currentPage=0;
        [self addSubview:_pageControl];
        
    }
    
}
-(void)addImage:(NSDictionary*)imageDict
{
    [ImagesDict addObject:imageDict];
    
    _pageControl.numberOfPages=[ImagesDict count];

    [_collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
 
    return [ImagesDict count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BannerCell*cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.data=ImagesDict[indexPath.row];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, 200);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat pageWidth = _collectionView.frame.size.width;
    float fractionalPage = _collectionView.contentOffset.x/pageWidth;
    NSInteger page = lround(fractionalPage);
    _pageControl.currentPage = page;
    [_collectionView reloadData];
    
}
@end
