//
//  YearMonthPickerView.h
//  AppDeck
//
//  Created by hanine ben saad on 20/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YearMonthPickerView : UIPickerView<UIPickerViewDelegate,UIPickerViewDataSource>{
    
    NSMutableArray*months;
}

-(id)initPickerviewWithFrame:(CGRect)frame andDateComponents:(NSDateComponents*)components;
-(void)onDateSelectedWithMonth:(int)month andYear:(int)year;
@end
