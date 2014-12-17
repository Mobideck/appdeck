//
//  MPIndexPathPickerView.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MPIndexPathPickerViewDelegate;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPIndexPathPickerView : UIView

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPIndexPathPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id<MPIndexPathPickerViewDelegate> delegate;
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) UIToolbar *toolbar;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPIndexPathPickerViewDelegate <NSObject>

- (NSInteger)numberOfSectionsForIndexPathPickerView:(MPIndexPathPickerView *)pickerView;
- (NSInteger)indexPathPickerView:(MPIndexPathPickerView *)pickerView numberOfItemsInSection:(NSInteger)section;
- (void)indexPathPickerView:(MPIndexPathPickerView *)pickerView didSelectIndexPath:(NSIndexPath *)indexPath;

@end
