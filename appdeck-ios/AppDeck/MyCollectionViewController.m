//
//  MyCollectionViewController.m
//  AppDeck
//
//  Created by hanine ben saad on 27/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "MyCollectionViewController.h"

#import "UIImageView+WebCache.h"
#import <Masonry/Masonry.h>

@interface customCell: UICollectionViewCell

@property(nonatomic,retain) UILabel*titleLabel;
@property(nonatomic,retain) UIImageView*imageView;
@property(nonatomic,retain) NSDictionary*data;

@end

@implementation customCell

static const CGFloat labelPadding = 10;
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    
    [self setup];
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat maxHeight = 9999;
    if (_titleLabel.numberOfLines > 0){
        maxHeight = _titleLabel.font.leading*_titleLabel.numberOfLines;
        CGSize textSize =[_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_titleLabel.font}];
        return CGSizeMake(size.width, textSize.height + labelPadding * 2);
    }

    return CGSizeZero;
}

-(void)layoutSubviews{
    
    CGSize captionLabelSize = [self sizeThatFits:self.bounds.size];
    _titleLabel.frame = CGRectMake(self.frame.size.width / 2 - captionLabelSize.width / 2,
                                    self.frame.size.height - captionLabelSize.height,
                                    captionLabelSize.width, captionLabelSize.height);
    
}

-(void)setData:(NSDictionary *)data{
    _titleLabel.text=data[@"caption"];

    [_imageView sd_setImageWithURL:[NSURL URLWithString:data[@"url"]]
                  placeholderImage:[UIImage imageNamed:@"Refresh_icon"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                      NSLog(@"error %@", error);
                  }];
}

-(void)setup{
    
    _titleLabel=[[UILabel alloc]init];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _titleLabel.opaque = NO;
    _titleLabel.textAlignment = NSTextAlignmentCenter;// UITextAlignmentCenter;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;// UILineBreakModeWordWrap;
    _titleLabel.numberOfLines = 3;
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:_titleLabel];

    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.bottom.equalTo(self.mas_bottom).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(-5);
    }];
    
    _imageView=[[UIImageView alloc] init];
    _imageView.contentMode=UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(5);
        make.left.equalTo(self.mas_left).with.offset(5);
        make.bottom.equalTo(_titleLabel.mas_top).with.offset(-3);
        make.right.equalTo(self.mas_right).with.offset(-5);
    }];
}

@end

@interface MyCollectionViewController ()

@end

@implementation MyCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if(!_collection){
        
        UICollectionViewFlowLayout *layout= [UICollectionViewFlowLayout new]; // standard flow layout
        
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collection = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        NSLog(@"%@",CGRectCreateDictionaryRepresentation(self.view.bounds));
        _collection.backgroundColor=[UIColor blackColor];
        _collection.delegate=self;
        _collection.dataSource=self;
        
        [_collection registerClass:[customCell class] forCellWithReuseIdentifier:reuseIdentifier];
        
        [self.view addSubview:_collection];
    }
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //_collection=[[UICollectionView alloc]init];
 
//    UICollectionViewFlowLayout*layout=[[UICollectionViewFlowLayout alloc]init];
//    self.collection.collectionViewLayout=layout;
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ((NSArray*)[_origin.param objectForKey:@"images"]).count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *) collectionView
                        layout:(UICollectionViewLayout *) collectionViewLayout
        insetForSectionAtIndex:(NSInteger) section {

    return UIEdgeInsetsMake(10, 0, 0,0); // top, left, bottom, right
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    customCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.data=[_origin.param objectForKey:@"images"][indexPath.row];
    cell.backgroundColor=[UIColor whiteColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width-20, 150);
}
@end


