//
//  ImageBannerTest.m
//  AppDeck
//
//  Created by hanine ben saad on 25/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "ImageBannerTest.h"
#import "iCarousel.h"


@implementation ImageBannerTest


@synthesize carousel;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [super awakeFromNib];
    array=@[@"previous.png",@"next.png",@"previous.png"];
    self.backgroundColor=[UIColor greenColor];
    // carousel=[[iCarousel alloc]initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
    carousel.type=iCarouselTypeLinear;
    carousel.backgroundColor=[UIColor redColor];
    
    carousel.dataSource=self;
    carousel.delegate=self;
    [carousel reloadData];
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    
    [self setup];
    return self;
}

-(void)setup
{

}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [array count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        ((UIImageView *)view).image =[UIImage imageNamed:array[index]];
        view.contentMode = UIViewContentModeCenter;
        label = [[UILabel alloc] initWithFrame:view.bounds];
       // label.backgroundColor = [UIColor clearColor];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.font = [label.font fontWithSize:50];
//        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = @"testttttt";
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return YES;
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
@end
