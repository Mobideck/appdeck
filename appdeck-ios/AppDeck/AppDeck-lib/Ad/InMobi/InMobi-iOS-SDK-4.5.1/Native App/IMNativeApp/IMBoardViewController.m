//
//  IMBoardViewController.m
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import "IMBoardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "IMUtilities.h"
#import "IMGlobalImageCache.h"
#import "IMContentViewController.h"
#define BOARD_URL @"https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=30&q=http://rss.nytimes.com/services/xml/rss/nyt/World.xml"

NSString* cellIdentifier = @"boardCell";

/* SAMPLE PUBCONTENT FOR BOARD
 {
    "title":"World at Arms - Wage war for your nation!",
    "contentSnippet":"LOCK AND LOAD! The evil KRA forces have attacked our nation, threatening the entire free world! A...",
    "link":"https://itunes.apple.com/app/world-at-arms-wage-war-for/id526713081",
    "icon":{
        "w":300,"url":"http://mkhoj-av.s3.amazonaws.com/526713081-sg-1397225945448",
        "h":300
    }
 }

 */

@interface IMBoardViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >

@property (nonatomic, strong) UICollectionView* collectionView;

@end

@implementation IMBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlLoaded:) name:URL_LOADED_NOTIFICATION object:nil];
    }
    return self;
}

-(void)loadNativeAd {
    self.native = [[IMNative alloc] initWithAppId:INMOBI_BOARDVIEW];
    self.native.delegate = self;
    [self.native loadAd];
}

-(NSString*)serverUrl {
    return BOARD_URL;
}

-(void)urlLoaded:(NSString*)url {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self reloadData];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController.navigationBar setTintColor:RGBToUIColor(101, 151, 213)];
    self.navigationItem.title = @"Board";

}

-(NSArray*)itemsFromJsonDict:(NSDictionary *)jsonDict {
    return [IMUtilities boardItemsFromJsonDict:jsonDict];
}

-(NSDictionary*)dictFromNativeContent {
    NSDictionary* dict =  [IMUtilities boardDictFromNativeContent:self.nativeContent];
    NSDictionary* iconDict = [dict valueForKey:@"icon"];
    NSString* adImageUrl = [iconDict valueForKey:@"url"];
    if (adImageUrl) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:adImageUrl]];
            UIImage* img = [UIImage imageWithData:imgData];
            [[IMGlobalImageCache sharedCache] addImage:img forKey:adImageUrl];
            [self reloadData];
        });
    }
    
    
    return dict;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [super connectionDidFinishLoading:connection];
    
    NSDictionary* nativeContentDict = [self dictFromNativeContent];
    
    if (nativeContentDict != nil) {
        [self.items insertObject:nativeContentDict atIndex:4];
    }
    
    [self.statusLabel removeFromSuperview];
    
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(120, 150);
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 0.0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0.0, 0, 0.0);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    self.collectionView.allowsSelection = YES;
    [self.view addSubview:self.collectionView];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [indexPath section] * ([self collectionView:collectionView numberOfItemsInSection:[indexPath section]]) + [indexPath row];
    
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    NSDictionary* dict = [self.items objectAtIndex:[newIndexPath row]];
    
    NSString* url = nil;
    IMContentViewController* content = [[IMContentViewController alloc] init];
    content.headerTitle = @"Board";
    url = [dict valueForKey:@"link"];
    if ([dict valueForKey:@"isAd"]) {
        NSURL* URL = [NSURL URLWithString:url];
        [[UIApplication sharedApplication] openURL:URL];
        [self.native handleClick:nil];
    }
    else {
        content.url = url;
        
        [self.navigationController pushViewController:content animated:YES];
    }
    
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.items count]/2;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        CGRect cellFrame = CGRectMake(0, 0, 120, 150);
        cell = [[UICollectionViewCell alloc] initWithFrame:cellFrame];
    }
    
    NSUInteger index = [indexPath section] * ([self collectionView:collectionView numberOfItemsInSection:[indexPath section]]) + [indexPath row];
    
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
    UIImageView* imgViewInCollectionView = (UIImageView*)[cell viewWithTag:IMG_TAG];
    UILabel* labelInCollectionView = (UILabel*)[cell viewWithTag:TITLE_TAG];
    UILabel* descriptionInCollectionView = (UILabel*)[cell viewWithTag:DESCRIPTION_TAG];
    UILabel* sponserdLabelInCollectionView = (UILabel*)[cell viewWithTag:SPONSERED_LABEL_TAG];
    if (imgViewInCollectionView == nil) {
        imgViewInCollectionView = [[UIImageView alloc] init];
        imgViewInCollectionView.tag = IMG_TAG;
    }
    if (labelInCollectionView == nil) {
        labelInCollectionView = [[UILabel alloc] init];
        labelInCollectionView.tag = TITLE_TAG;
    }
    if (descriptionInCollectionView == nil) {
        descriptionInCollectionView = [[UILabel alloc] init];
        descriptionInCollectionView.tag = DESCRIPTION_TAG;
    }
    if (sponserdLabelInCollectionView != nil) {
        [sponserdLabelInCollectionView removeFromSuperview];
    }
    
    [imgViewInCollectionView removeFromSuperview];
    [labelInCollectionView removeFromSuperview];
    [descriptionInCollectionView removeFromSuperview];
    
    labelInCollectionView.backgroundColor = [UIColor clearColor];
    descriptionInCollectionView.backgroundColor = [UIColor clearColor];
    imgViewInCollectionView.backgroundColor = [UIColor clearColor];
    
    UIFont* boldFont = [UIFont fontWithName:@"Open Sans Bold" size:13];
    UIFont* plainFont = [UIFont fontWithName:@"Open Sans" size:11];

    NSDictionary* dict = [self.items objectAtIndex:[newIndexPath row]];
    
    labelInCollectionView.text = [dict valueForKey:@"title"];
    descriptionInCollectionView.text = [dict valueForKey:@"content"];
    NSURL* imageUrl = [IMUtilities getImageURLFromBoardDict:dict];
    UIImage* image = [[IMGlobalImageCache sharedCache] imageForKey:[imageUrl absoluteString]];
    imgViewInCollectionView.image = image;
    
    if ([dict valueForKey:@"isAd"]) {
        
        //Render the ad.
        descriptionInCollectionView.text = [dict valueForKey:@"contentSnippet"];
        NSDictionary* iconDict = [dict valueForKey:@"icon"];
        NSString* adImageUrl = [iconDict valueForKey:@"url"];
        if (adImageUrl) {
            imgViewInCollectionView.image = [[IMGlobalImageCache sharedCache] imageForKey:adImageUrl];
        }

        UILabel* sponseredLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 155, 40, 15)];
        sponseredLabel.tag = SPONSERED_LABEL_TAG;
        sponseredLabel.backgroundColor=[UIColor clearColor];
        sponseredLabel.lineBreakMode = NSLineBreakByWordWrapping;
        sponseredLabel.numberOfLines = 0;
        UIFont* font = [UIFont fontWithName:@"Open Sans" size:8];
        sponseredLabel.font = font;
        sponseredLabel.text = @"AD";
        [cell addSubview:sponseredLabel];
        
        [self attachNativeAdToView:cell];
        
    }

    if (index % 4 == 1 || index %4 == 2) {
        labelInCollectionView.frame = CGRectMake(10, 10, 100, 60);
        labelInCollectionView.lineBreakMode = NSLineBreakByWordWrapping;
        labelInCollectionView.numberOfLines = 0;
        labelInCollectionView.font = boldFont;
        
        descriptionInCollectionView.frame = CGRectMake(10, 80, 100, 50);
        descriptionInCollectionView.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionInCollectionView.numberOfLines = 0;
        descriptionInCollectionView.font = plainFont;
        
        [cell addSubview:labelInCollectionView];
        [cell addSubview:descriptionInCollectionView];

    }
    else {
        imgViewInCollectionView.frame = CGRectMake(10, 10, 100, 80);
        labelInCollectionView.frame = CGRectMake(10, 100, 100, 30);
        labelInCollectionView.lineBreakMode = NSLineBreakByWordWrapping;
        labelInCollectionView.numberOfLines = 0;
        labelInCollectionView.font = plainFont;
        
        [cell addSubview:imgViewInCollectionView];
        [cell addSubview:labelInCollectionView];
    }
    
    cell.backgroundColor = RGBToUIColor(211, 211, 211);
    return cell;
}

#pragma mark IMNativeDelegate Methods

-(void)nativeAdDidFinishLoading:(IMNative *)native { //DUPLICATING CODE FOR BETTER UNDERSTANDING
    
    const char* nativeCString = [native.content cStringUsingEncoding:NSISOLatin1StringEncoding];
    
    NSString* utf8PubContent = [[NSString alloc] initWithCString:nativeCString encoding:NSUTF8StringEncoding];
    
    NSLog(@"Native ad content after encoding is %@", utf8PubContent);
    
    self.nativeContent = utf8PubContent;
    
    NSLog(@"JSON content is %@", self.nativeContent);
    
    NSDictionary* nativeJson = [self dictFromNativeContent];
    
    if (self.items.count > 0 && nativeJson!=nil) {
        [self.items insertObject:nativeJson atIndex:4];
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(void)nativeAd:(IMNative *)native didFailWithError:(IMError *)error {
    NSLog(@"Native ad failed with error %@", error);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150, 180);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadData {
    [self.collectionView reloadData];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
