//
//  SelectActionSheet.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 21/10/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectActionSheet : UIActionSheet<UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSString *title;
    NSArray *values;
    UIPickerView *picker;
    NSDate*cDate;
}

-(id)initWithTitle:(NSString *)title andValues:(NSArray *)values;
-(id)initWithTitle:(NSString *)title andDate:(NSDate *)date;
-(void)postSetup;
@end
