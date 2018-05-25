//
//  myCell.m
//  AppDeck
//
//  Created by hanine ben saad on 24/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "myCell.h"
#import "UIImageView+WebCache.h"
#import <Masonry/Masonry.h>
#import "AppURLCache.h"
#import "NSString+UIColor.h"
#import "LoaderConfiguration.h"
#import "GradientView.h"

@implementation myCell


@synthesize imageView;
@synthesize paddingView;
@synthesize delegate;
@synthesize titleLabel;
@synthesize dateLabel;
@synthesize containerView;
@synthesize globalData;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews{

    self.backgroundColor=[UIColor clearColor];
    
}

-(void)setDataa:(NSDictionary *)dataa{
    
    _dataa=dataa;
    
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:dataa[@"thumbnail"] relativeToURL:delegate.url]];
    
    
    NSCachedURLResponse *cachedResponse = [delegate.loader.appDeck.cache getCacheResponseForRequest:request];
    
    if (cachedResponse)
    {
        // [self setImageFromData:cachedResponse.data forState:state];
    }
    else
    {
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *dataaa, NSURLResponse *response, NSError *error)
                                      {
                                          if (error == nil)
                                          {
                                              dispatch_async(dispatch_get_main_queue(), ^
                                                             {
                                                                 
                                                                 imageView.image = [UIImage imageWithData:dataaa];
                                                             });
                                          }
                                          else
                                              NSLog(@"Failed to download icon: %@: %@", _dataa[@"url"], error);
                                      }];
        
        [task resume];
        
    }
    
    titleLabel.text=dataa[@"caption"];
    
    dateLabel.text=[self returnDateFormat:dataa[@"date"]];
    
    
    NSString*color=[NSString stringWithFormat:@"%@",globalData[@"cellbgcolor"]];
    
    containerView.backgroundColor=[[color toUIColor] colorWithAlphaComponent:[globalData[@"cellbgalpha"] floatValue]];
    
    if (delegate.loader.conf.app_topbar_color1 && delegate.loader.conf.app_topbar_color2){
        [paddingView setGradientViewWithcolors:@[(id)[delegate.loader.conf.app_topbar_color1 CGColor],(id)[delegate.loader.conf.app_topbar_color2 CGColor]]];
    }

}
   
- (CALayer *)gradientBGLayerForBounds:(CGRect)bounds colors:(NSArray *)colors
{
    CAGradientLayer * gradientBG = [CAGradientLayer layer];
    gradientBG.frame = bounds;
    gradientBG.colors = colors;
    return gradientBG;
}


-(NSString*)returnDateFormat:(NSString*)dateStr{
    
    NSString*returnStr;
    NSDateFormatter*dateFormatterGet=[[NSDateFormatter alloc] init];
    [dateFormatterGet setLocale:[NSLocale localeWithLocaleIdentifier:@"fr"]];
    [dateFormatterGet setDateFormat:@"dd-MM-yyy HH:mm:ss"];
    NSDate*date=[dateFormatterGet dateFromString:dateStr];
    if ([[NSCalendar currentCalendar] isDateInToday:date]) {
        [dateFormatterGet setDateFormat:@"HH:mm"];
        returnStr=[dateFormatterGet stringFromDate:date];
    }else if ([[NSCalendar currentCalendar] isDateInYesterday:date]){
        [dateFormatterGet setDateFormat:@"HH:mm"];
        returnStr=[NSString stringWithFormat:@"Hier %@",[dateFormatterGet stringFromDate:date]];
    }else{
        [dateFormatterGet setDateFormat:@"EEEE, dd MMM HH:mm"];
        returnStr=[dateFormatterGet stringFromDate:date];
    }
    return returnStr;
}

//-(void)setup{
//
//    containerView=[[UIView alloc]init];
//    containerView.backgroundColor=[UIColor grayColor];
//    [self addSubview:containerView];
//    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top).with.offset(5);
//        make.left.equalTo(self.mas_left).with.offset(5);
//        make.right.equalTo(self.mas_right).with.offset(-5);
//        make.bottom.equalTo(self.mas_bottom).with.offset(-5);
//    }];
//
//    paddingView=[[UIView alloc]init];
//    paddingView.backgroundColor=[UIColor orangeColor];
//    [containerView addSubview:paddingView];
//
//
//    [paddingView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(containerView.mas_top);
//        make.left.equalTo(containerView.mas_left);
//        make.bottom.equalTo(containerView.mas_bottom);
//        make.width.equalTo(@8);
//    }];
//
//    titleLabel=[[UILabel alloc]init];
//    titleLabel.backgroundColor=[UIColor yellowColor];
//    [containerView addSubview:titleLabel];
//
//    imageView=[[UIImageView alloc] init];
//    imageView.contentMode=UIViewContentModeScaleAspectFit;
//    imageView.backgroundColor=[UIColor whiteColor];
//    [containerView addSubview:imageView];
//
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(containerView.mas_top).with.offset(5);
//        make.left.equalTo(paddingView.mas_right).with.offset(5);
//        // make.bottom.equalTo(containerView.mas_bottom).with.offset(-5);
//        //  make.width.equalTo(@60);
//    }];
//
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(imageView.mas_bottom);
//        make.left.equalTo(paddingView.mas_right);
//        make.bottom.equalTo(containerView.mas_bottom);
//        make.right.equalTo(containerView.mas_right);
//    }];
//
//    //    CGRect fr=containerView.frame;
//    //    fr.size.height=titleLabel.frame.size.height+imageView.frame.size.height+10;
//    //    containerView.frame=fr;
//
//
//    [self layoutSubviews];
//
//}


@end
