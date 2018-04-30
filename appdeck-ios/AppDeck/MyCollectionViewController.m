//
//  MyCollectionViewController.m
//  AppDeck
//
//  Created by hanine ben saad on 27/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "MyCollectionViewController.h"


@interface customCell: UICollectionViewCell

@property(nonatomic,retain) UILabel*text;

@end

@implementation customCell

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    
    [self setup];
    return self;
}

-(void)setup{
    
    _text=[[UILabel alloc]initWithFrame:self.bounds];
    _text.backgroundColor=[UIColor greenColor];
    [self addSubview:_text];
}

//-(void)layoutSubviews{
//    [super layoutSubviews];
//
//}

@end

@interface MyCollectionViewController ()

@end

@implementation MyCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if(!_collection){
     //   _collection.frame=self.view.bounds;
        
        UICollectionViewFlowLayout *layout= [UICollectionViewFlowLayout new]; // standard flow layout
        
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
//        [layout setMinimumInteritemSpacing:0.0f];
//        [layout setMinimumLineSpacing:0.0f];
        _collection = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        NSLog(@"%@",CGRectCreateDictionaryRepresentation(self.view.bounds));
        _collection.backgroundColor=[UIColor redColor];
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
    return [[_origin.param objectForKey:@"nb_rows"] intValue];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    customCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.text.text=@"teste";
    cell.backgroundColor=[UIColor greenColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(150, 150);
}
@end


