//
//  IMCoverFlowViewController.m
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import "IMCoverFlowViewController.h"
#import "IMBaseViewController.h"    //Only for RGBToUIColor

/* SAMPLE PUBCONTENT FOR COVERFLOW
 {
    "title":"World at Arms - Wage war for your nation!",
    "link":"https://itunes.apple.com/app/world-at-arms-wage-war-for/id526713081",
    "image":{
        "w":320,"url":"http://mkhoj-av.s3.amazonaws.com/526713081-IOS-sg-5106985w320h180",
        "h":180
    }
 }
 */

@interface IMCoverFlowViewController ()
@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic, strong) iCarousel *carousel;
@property(nonatomic) NSString *imageUrl;
@property(nonatomic) BOOL gotResponse;
@end

@implementation IMCoverFlowViewController
@synthesize carousel;

- (void)setUp {
    UIImage *img1 = [UIImage imageNamed:@"coverflow1.png"];
    UIImage *img2 = [UIImage imageNamed:@"coverflow2.png"];
    UIImage *img3 = [UIImage imageNamed:@"coverflow3.png"];
    UIImage *img4 = [UIImage imageNamed:@"coverflow4.png"];
    UIImage *img5 = [UIImage imageNamed:@"coverflow5.png"];
    UIImage *img6 = [UIImage imageNamed:@"coverflow6.png"];
    UIImage *img7 = [UIImage imageNamed:@"coverflow7.png"];
    UIImage *img8 = [UIImage imageNamed:@"coverflow8.png"];
    _items = [NSMutableArray arrayWithObjects:img1,img2,img3,img4,img5,img6,img7,img8, nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setUp];
        _gotResponse = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Integration of Inmobi SDK
    [self getInmobiNativeAd];

//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpeg"]];
    [self.navigationController.navigationBar setTintColor:RGBToUIColor(101, 151, 213)];
    UIView *carouselView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, (self.view.bounds.size.width)-20, (self.view.bounds.size.height)-60)];
    //UIView *carouselView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 400)];
    [self.view addSubview:carouselView];

    carousel = [[iCarousel alloc] initWithFrame:carouselView.bounds];
    carousel.delegate = self;
    carousel.dataSource = self;
    carousel.type = iCarouselTypeCoverFlow;
    self.navigationItem.title = @"Flow";
    [carouselView addSubview:carousel];
}

- (void)getInmobiNativeAd {
    nativeAd = [[IMNative alloc] initWithAppId:INMOBI_COVERFLOW];
    nativeAd.delegate = self;
    [nativeAd loadAd];
}

#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [_items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
        if (index%3==0) {
            if (_gotResponse) {
                dispatch_async(dispatch_get_global_queue(0,0), ^{
                    NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:_imageUrl]];
                    if ( data == nil )
                        return;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ((UIImageView *)view).image = [UIImage imageWithData: data];
                    });
                });
            } else {
                ((UIImageView *)view).image = [_items objectAtIndex:index];
            }
        } else {
            ((UIImageView *)view).image = [_items objectAtIndex:index];
        }
        view.contentMode = UIViewContentModeCenter;
    }
    return view;
}


- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}


#pragma mark iCarousel taps

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    NSNumber *item = (_items)[index];
    NSLog(@"Tapped view number: %@", item);
}

#pragma mark NativeDelegate methods
- (void)nativeAdDidFinishLoading:(IMNative *)native {
    _gotResponse = true;
    NSLog(@"Carousel native content %@", native.content);
    [nativeAd attachToView:self.view];
    NSString *pubContent = nativeAd.content;
    NSData *pubData = [pubContent dataUsingEncoding:NSUTF8StringEncoding];

    if(NSClassFromString(@"NSJSONSerialization")) {
        NSError *error = nil;
        id parsedJson = [NSJSONSerialization
                     JSONObjectWithData:pubData
                     options:0
                     error:&error];

        if(error) {
            NSLog(@"Error:%@",error.description);
        }

        if([parsedJson isKindOfClass:[NSDictionary class]]) {
            NSDictionary *results = parsedJson;
            //get the image url
            NSDictionary *image = [results objectForKey:@"image"];
            _imageUrl = [image objectForKey:@"url"];
        }
        else {
            NSLog(@"Not a valid json");
        }
    }
    else {
        //Use third party json parser
    }
    [carousel reloadData];
}

- (void)nativeAd:(IMNative *)native didFailWithError:(IMError *)error {
    _gotResponse = false;
    NSLog(@"failed to get native ad with error %@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
