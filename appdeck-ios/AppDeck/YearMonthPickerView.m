//
//  YearMonthPickerView.m
//  AppDeck
//
//  Created by hanine ben saad on 20/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "YearMonthPickerView.h"

@implementation YearMonthPickerView

static const NSInteger DefaultMinimumYear = 1;
static const NSInteger DefaultMaximumYear = 9000;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initPickerviewWithFrame:(CGRect)frame andDateComponents:(NSDateComponents*)components {
    self=[super initWithFrame:frame];
    
    self.dataSource=self;
    self.delegate=self;
    
    if (!months)
        months=[NSMutableArray array];
    
    int monthh = 0;
    while (monthh<12) {
        NSDateFormatter*formatter=[[NSDateFormatter alloc]init];
        [months addObject:[formatter monthSymbols][monthh].capitalizedString];
        monthh+=1;
    }
    
    [self setDateFromComponents:components];

    
    return self;
    
}

-(void)setDateFromComponents:(NSDateComponents *)components
{
    components.timeZone = [NSTimeZone defaultTimeZone];

    [self selectRow:(int)components.month-1 inComponent:0 animated:YES];
    [self selectRow:(int)components.year inComponent:1 animated:YES];

}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component==0)
        return months.count;
    else
        return DefaultMaximumYear+1;
}

-(void)onDateSelectedWithMonth:(int)month andYear:(int)year{
    
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
     if (component==0)
        return months[row];
    else
        return [NSString stringWithFormat:@"%ld",(long)row];
    
    return @"";
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
//    int month =(int) [self selectedRowInComponent:0]+1;
//    int year =(int)(DefaultMaximumYear-row);
//    [self onDateSelectedWithMonth:month andYear:year];
}

@end
