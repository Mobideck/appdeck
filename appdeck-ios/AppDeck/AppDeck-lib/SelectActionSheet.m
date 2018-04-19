//
//  SelectActionSheet.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 21/10/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "SelectActionSheet.h"

@implementation SelectActionSheet

-(id)initWithTitle:(NSString *)t andValues:(NSArray *)v
{
    self = [super initWithTitle:t delegate:self cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles: nil];
    if (self) {
        // Initialization code
        title = t;
        values = v;
        [self setValues:values];
    }
    return self;
}

-(id)initWithTitle:(NSString *)title andDate:(NSDate *)date{
    self = [super initWithTitle:title delegate:self cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles: nil];
    if (self) {
        // Initialization code
        title = title;
        cDate = date;
        [self setDate:cDate];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setDate:(NSDate*)date{
    UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 20, 320, 120)];
    pickerView.date = date;
    pickerView.datePickerMode = UIDatePickerModeDate;
    [self addSubview:pickerView];
}

-(void)setValues:(NSArray *)values
{
    picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
 
    [self addSubview:picker];

    // Add the picker
  
}

-(void)postSetup
{
    [self setBounds:CGRectMake(0, 0, 320, 500)];
    
    CGRect pickerRect = picker.bounds;
    pickerRect.origin.y = -100;
    picker.bounds = pickerRect;
    
    [self bringSubviewToFront:picker];
}

#pragma mark - picker view

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger ret = [values count];
    return ret;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"test";
    return [values objectAtIndex:row];
}
/*
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.text = [values objectAtIndex:row];
    label.frame = CGRectMake(0, 0, 320, 50);
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 320;
}
*/
@end
