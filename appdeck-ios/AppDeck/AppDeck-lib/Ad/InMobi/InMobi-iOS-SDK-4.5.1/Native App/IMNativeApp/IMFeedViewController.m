//
//  IMFeedViewController.m
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#define FEED_URL @"https://api.instagram.com/v1/users/595017071/media/recent?client_id=8ff39eb66c424c89ad26adfb0dd1ca2c"

#import "IMFeedViewController.h"
#import "IMGlobalImageCache.h"
#import "IMContentViewController.h"

/* SAMPLE PUBCONTENT FOR FEED
 {
    "title":"World at Arms - Wage war for your nation!",
    "contentSnippet":"LOCK AND LOAD! The evil KRA forces have attacked our nation, threatening the entire free world! A...",
    "link":"https://itunes.apple.com/app/world-at-arms-wage-war-for/id526713081",
    "icon":{
        "w":300,
        "url":"http://mkhoj-av.s3.amazonaws.com/526713081-sg-1397225945448",
        "h":300
    },
    "image":{
        "w":320,
        "url":"http://mkhoj-av.s3.amazonaws.com/526713081-IOS-sg-5106985w320h180",
        "h":180
    },
    "rating":"4.5"
 }
 */

@interface IMFeedViewController ()

@end

@implementation IMFeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSString*)serverUrl {
    return FEED_URL;
}

-(void)loadNativeAd {
    self.native = [[IMNative alloc] initWithAppId:INMOBI_FEEDS];
    self.native.delegate = self;
    [self.native loadAd];
}

-(NSArray*)itemsFromJsonDict:(NSDictionary*)jsonDict {
    NSArray* array = nil;
    if (jsonDict == nil) {
        return array;
    }
    
    array = [jsonDict valueForKey:@"data"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        for (NSDictionary* data in array) {
            
            //image
            NSDictionary* imagesDict = [data objectForKey:@"images"];
            NSDictionary* standardImage = [imagesDict objectForKey:@"standard_resolution"];
            NSString* url = [standardImage objectForKey:@"url"];
            
            
            NSData* iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            UIImage* icon = [UIImage imageWithData:iconData];
            
            [[IMGlobalImageCache sharedCache] addImage:icon forKey:url];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self reloadData];
            });
        }
        
    });
    return array;
}

-(NSDictionary*)dictFromNativeContent {
    if (self.nativeContent==nil) {
        return nil;
    }
    NSData* data = [self.nativeContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSMutableDictionary* nativeJsonDict = [NSMutableDictionary dictionaryWithDictionary:jsonDict];
    if (error == nil && nativeJsonDict != nil) {
        [nativeJsonDict setValue:[NSNumber numberWithBool:YES] forKey:@"isAd"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            
            NSDictionary* imageDict = [nativeJsonDict valueForKey:@"icon"];
            
            NSString* url = [imageDict valueForKey:@"url"];
            
            NSURL* imgURL = [NSURL URLWithString:url];
            
            NSData* rawImgdata = [NSData dataWithContentsOfURL:imgURL];
            UIImage* image = [UIImage imageWithData:rawImgdata];
            IMGlobalImageCache* cache = [IMGlobalImageCache sharedCache];
            [cache addImage:image forKey:url];
        });
    }
    return nativeJsonDict;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController.navigationBar setTintColor:RGBToUIColor(101, 151, 213)];
    self.navigationItem.title = @"Feed";
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection { //OVERRIDING FROM IMNewsViewController
    [super connectionDidFinishLoading:connection];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { // OVERRIDING FROM IMNewsViewController
    return 200;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { // OVERRIDING FROM IMNewsViewController

    NSString* cellIdentifier = @"feedCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView* prevImg = (UIImageView*)[cell viewWithTag:IMG_TAG];
    UILabel* prevTitle = (UILabel*)[cell viewWithTag:TITLE_TAG];
    UILabel* prevDesc = (UILabel*)[cell viewWithTag:DESCRIPTION_TAG];
    if (prevDesc!=nil && prevImg!=nil && prevTitle!=nil) {
        [prevTitle removeFromSuperview];
        [prevDesc removeFromSuperview];
        [prevImg removeFromSuperview];
    }
    
    UIImageView* imgView = [[UIImageView alloc] init];
    imgView.tag = IMG_TAG;
    imgView.frame = CGRectMake(25, 40, 160, 120);
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, cell.frame.size.width - 25, 20)];
    titleLabel.tag = TITLE_TAG;
    
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.numberOfLines = 0;
    UIFont* titleLabelFont = [UIFont fontWithName:@"Open Sans Bold" size:14];
    titleLabel.font = titleLabelFont;
    
    UILabel* descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 160, cell.frame.size.width - 35, 30)];
    descriptionLabel.tag = DESCRIPTION_TAG;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptionLabel.numberOfLines = 0;
    UIFont* descriptionFont = [UIFont fontWithName:@"Open Sans" size:10];
    descriptionLabel.font = descriptionFont;
    
    NSDictionary* data = [self.items objectAtIndex:[indexPath row]];
    //image
    if ([data valueForKey:@"isAd"]) {
        
        titleLabel.text = [data objectForKey:@"title"];
        descriptionLabel.text = [data objectForKey:@"contentSnippet"];
        NSDictionary* icon = [data objectForKey:@"icon"];
        NSString* iconUrl = [icon objectForKey:@"url"];
        imgView.image = [[IMGlobalImageCache sharedCache] imageForKey:iconUrl];
        
        [cell addSubview:imgView];
        [cell addSubview:titleLabel];
        [cell addSubview:descriptionLabel];
        
        [self attachNativeAdToView:cell];
        
        return cell;
    }
    NSDictionary* imagesDict = [data objectForKey:@"images"];
    NSDictionary* standardImage = [imagesDict objectForKey:@"standard_resolution"];
    NSString* url = [standardImage objectForKey:@"url"];
    
    
    NSDictionary* caption = [data objectForKey:@"caption"];
    NSString* text = [caption objectForKey:@"text"];
    //username
    NSDictionary* from = [caption objectForKey:@"from"];
    NSString* userName = [from objectForKey:@"username"];
    
    titleLabel.text = userName;
    descriptionLabel.text = text;
    
    UIImage* image = [[IMGlobalImageCache sharedCache] imageForKey:url];

    imgView.image = image;
    
    [cell addSubview:imgView];
    [cell addSubview:titleLabel];
    [cell addSubview:descriptionLabel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { // REPEATING CODE FROM IMNEWSVIEWCONTROLLER FOR UNDERSTANDING
    NSDictionary* dict = [self.items objectAtIndex:[indexPath row]];
    NSString* url = nil;
    IMContentViewController* content = [[IMContentViewController alloc] init];
    content.headerTitle = @"Feed";
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
