//
//  MySlider.m
//  AppDeck
//
//  Created by hanine ben saad on 24/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "MySlider.h"
#import "AppDeckApiCall.h"

@interface MySlider ()

@property (nonatomic, retain) AppDeckApiCall*call;
@property (nonatomic, retain) UIView*SliderView;
@property (nonatomic, retain) UISlider*slider;
@property (nonatomic, retain) UILabel*sliderValue;

@end


@implementation MySlider

-(id)initWithFrame:(CGRect)frame{
    
    self=[super initWithFrame:frame];
    if (self) {
//[self initialize];
    }
   
    return self;
}

-(void)showInController:(UIViewController*)vc fromCall:(AppDeckApiCall*)mcall{
    
    self.call=mcall;
    [self initializeSliderViewInView:vc.view];
}


-(void)initializeSliderViewInView:(UIView*)view{
    
    
    [self setFrame: view.bounds];
    [self setBackgroundColor:[UIColor clearColor]];
    
    _SliderView=[[UIView alloc]initWithFrame:CGRectMake(20, view.frame.size.height-100, view.frame.size.width-40, 80)];
    _SliderView.backgroundColor=[UIColor colorWithWhite:0 alpha:.7];
    _SliderView.layer.cornerRadius=10;
    _SliderView.layer.masksToBounds=YES;
    
    _slider=[[UISlider alloc]initWithFrame:CGRectMake(10, 20, _SliderView.frame.size.width-20, 20)];
    
    [_slider setBackgroundColor:[UIColor clearColor]];
    _slider.minimumValue = [[self.call.param objectForKey:@"min"] floatValue];
    _slider.maximumValue = [[self.call.param objectForKey:@"max"] floatValue];
    _slider.continuous = YES;
    _slider.value = [[self.call.param objectForKey:@"value"] floatValue];
    [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

    
    [_SliderView addSubview:_slider];
    
    _sliderValue=[[UILabel alloc]initWithFrame:CGRectMake(_SliderView.frame.size.width/2-50, 40, 100, 30)];
    [_sliderValue setTextAlignment:NSTextAlignmentCenter];
    _sliderValue.textColor=[UIColor whiteColor];
     _sliderValue.text=[NSString stringWithFormat:@"%.2f",[[self.call.param objectForKey:@"value"] floatValue]];
    
    [_SliderView addSubview:_sliderValue];
    
    [self addSubview:_SliderView];
    
    
    [view addSubview:self];
    
}

-(void)valueChanged:(UISlider*)sender{
     //[self.call performSelectorOnMainThread:@selector(sendCallbackWithResult:) withObject:@[@(sender.value)] waitUntilDone:NO];
    
    _sliderValue.text=[NSString stringWithFormat:@"%.2f",sender.value];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
