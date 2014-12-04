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
}

-(id)initWithTitle:(NSString *)title andValues:(NSArray *)values;
-(void)postSetup;
@end
