//
//  IMNewsViewController.m
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//


#import "IMNewsViewController.h"
#import "IMNative.h"
#import "IMNativeDelegate.h"
#import "IMContentViewController.h"
#import "IMGlobalImageCache.h"
#import "IMUtilities.h"


/* SAMPLE PUBCONTENT FOR NEWS 
 
 {
    "title":"World at Arms - Wage war for your nation!",
    "contentSnippet":"LOCK AND LOAD! The evil KRA forces have attacked our nation, threatening the entire free world! A...",
    "link":"https://itunes.apple.com/app/world-at-arms-wage-war-for/id526713081",
    "icon":{
        "w":300,"url":"http://mkhoj-av.s3.amazonaws.com/526713081-sg-1397225945448","h":300
    }
 }
 
 */


#define NEWS_URL @"https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=30&q=http://rss.nytimes.com/services/xml/rss/nyt/World.xml"

#define NEWS_TITLE_WIDTH_PADDING 20
#define NEWS_DESCRIPTION_WIDTH_PADDING 20

@interface IMNewsViewController () 

@end

@implementation IMNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlLoaded:) name:URL_LOADED_NOTIFICATION object:nil];
    }
    return self;
}

-(NSString*)serverUrl {
    return NEWS_URL;
}

-(void)loadNativeAd {
    self.native = [[IMNative alloc] initWithAppId:INMOBI_NEWSFEED];
    self.native.delegate = self;
    [self.native loadAd];
}

-(NSArray*)itemsFromJsonDict:(NSDictionary*)jsonDict {

    return [IMUtilities newsItemsFromJsonDict:jsonDict];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"News";
 
    self.numRowsInTableView = 5;
    
    self.newsTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.newsTableView.dataSource = self;
    self.newsTableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSDictionary*)dictFromNativeContent {
    return [IMUtilities newsDictFromNativeContent:self.nativeContent];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection { // OVERRIDING NSURLConnectionDataDelegate Method FROM IMBASEVIEWCONTROLLER
    [super connectionDidFinishLoading:connection];

    NSDictionary* nativeContentDict = [self dictFromNativeContent];
    
    if (nativeContentDict != nil) {
        [self.items insertObject:nativeContentDict atIndex:4];
    }
    
    [self.statusLabel removeFromSuperview];
    
    [self.view addSubview:self.newsTableView];
    self.newsTableView.frame = self.view.bounds;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightOfCellForCurrentOrientation];
}

-(void)urlLoaded:(NSString*)url {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self reloadData];
    });
    
}

-(NSUInteger)widthtOfCellForCurrentOrientation {
    CGRect screenFrame = [UIApplication sharedApplication].keyWindow.bounds;
    return screenFrame.size.width;
}

-(NSUInteger)heightOfCellForCurrentOrientation {
    
    return 80;
}

-(CGRect)frameForCellAtCurrentOrientation {
    
    NSUInteger height = [self heightOfCellForCurrentOrientation];
    NSUInteger width = [self widthtOfCellForCurrentOrientation];
    
    CGRect cellFrame = CGRectMake(0, 0, width, height);
    
    return cellFrame;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"newsCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    CGRect cellBounds = CGRectMake(0, 0, self.view.frame.size.width, cellHeight);
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    UIImageView* prevImg = (UIImageView*)[cell viewWithTag:IMG_TAG];
    UILabel* prevTitle = (UILabel*)[cell viewWithTag:TITLE_TAG];
    UILabel* prevDesc = (UILabel*)[cell viewWithTag:DESCRIPTION_TAG];
    UILabel* prevSponseredLabel = (UILabel*)[cell viewWithTag:SPONSERED_LABEL_TAG];
    
    if (prevDesc!=nil && prevImg!=nil && prevTitle!=nil) {
        [prevTitle removeFromSuperview];
        [prevDesc removeFromSuperview];
        [prevImg removeFromSuperview];
    }
    
    if (prevSponseredLabel!=nil) {
        [prevSponseredLabel removeFromSuperview];
    }
    
    NSUInteger row = [indexPath row];
    NSDictionary* dict = [self.items objectAtIndex:row];
    NSURL* imageUrl = nil;
    
    //Create image
    CGRect imageFrame = CGRectMake(10, 10, 60, 60);

    UIImageView* imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    imageView.tag = IMG_TAG;
    
    [cell addSubview:imageView];
    
    //create headline
    UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 + 60, 10, cellBounds.size.width - (20 + 60 + NEWS_TITLE_WIDTH_PADDING), 30)];
    textLabel.tag = TITLE_TAG;
    
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.numberOfLines = 0;
    UIFont* titleLabelFont = [UIFont fontWithName:@"Open Sans Bold" size:14];
    textLabel.font = titleLabelFont;
    
    [cell addSubview:textLabel];
    
    UILabel* descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 + 60, 35, cellBounds.size.width - (20 + 60 + NEWS_DESCRIPTION_WIDTH_PADDING), 30)];
    descriptionLabel.tag = DESCRIPTION_TAG;
    
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptionLabel.numberOfLines = 0;
    UIFont* descriptionFont = [UIFont fontWithName:@"Open Sans" size:10];
    descriptionLabel.font = descriptionFont;
    [cell addSubview:descriptionLabel];
    
    textLabel.text = [dict valueForKey:@"title"];
    
    if ([dict valueForKey:@"isAd"] != nil) { // this is an ad
        
        descriptionLabel.text = [dict valueForKey:@"title"];
        
        NSDictionary* icon = [dict valueForKey:@"icon"];
        
        imageUrl = [NSURL URLWithString:[icon valueForKey:@"url"]];
        
        //Attach the cell to the Native Ad
        [self attachNativeAdToView:cell];
        
        UILabel* sponseredLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.size.width-60, 0, 40, 15)];
        sponseredLabel.tag = SPONSERED_LABEL_TAG;
        UIFont* font = [UIFont fontWithName:@"Open Sans" size:8];
        sponseredLabel.font = font;
        sponseredLabel.text = @"Sponsered";
        sponseredLabel.textColor = [UIColor lightGrayColor];
        [cell addSubview:sponseredLabel];
    }
    else {
        descriptionLabel.text = [dict valueForKey:@"content"];
        imageUrl = [IMUtilities getImageURLFromNewsDict:dict];
    
    }
    UIImage* image = [[IMGlobalImageCache sharedCache] imageForKey:[imageUrl absoluteString]];
    imageView.image = image;
    
    return cell;
}

-(void)attachNativeAdToView:(UIView*)view {
    [self.native attachToView:view];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* dict = [self.items objectAtIndex:[indexPath row]];
    NSString* url = nil;
    IMContentViewController* content = [[IMContentViewController alloc] init];
    content.headerTitle = @"News";
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSDictionary*)newsDictFromNativeContent {
    
    if (self.nativeContent==nil) {
        return nil;
    }
    NSData* data = [self.nativeContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSMutableDictionary* nativeJsonDict = [NSMutableDictionary dictionaryWithDictionary:jsonDict];
    if (error == nil && nativeJsonDict != nil) {
        [nativeJsonDict setValue:[NSNumber numberWithBool:YES] forKey:@"isAd"];
        [self.items insertObject:nativeJsonDict atIndex:4]; //4th row will be an ad.
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {

            NSDictionary* imageDict = [nativeJsonDict valueForKey:@"icon"];
            
            NSString* url = [imageDict valueForKey:@"url"];
            
            NSURL* imgURL = [NSURL URLWithString:url];
            
            NSData* rawImgdata = [NSData dataWithContentsOfURL:imgURL];
            UIImage* image = [UIImage imageWithData:rawImgdata];
            [[IMGlobalImageCache sharedCache] addImage:image forKey:[imgURL absoluteString]];
            
            [self reloadData];
        });
    }
    return nativeJsonDict;
}

#pragma mark native delegate methods
-(void)nativeAdDidFinishLoading:(IMNative*)native {
    
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

-(void)nativeAd:(IMNative*)native didFailWithError:(IMError*)error {
    NSLog(@"Native ad failed to load with error %@", error);
}

-(void)reloadData {
    [self.newsTableView reloadData];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
