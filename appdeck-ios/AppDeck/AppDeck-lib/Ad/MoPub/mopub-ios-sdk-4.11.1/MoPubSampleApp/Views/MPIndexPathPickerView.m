//
//  MPIndexPathPickerView.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPIndexPathPickerView.h"

@implementation MPIndexPathPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        self.toolbar = [[UIToolbar alloc] init];
        [self.toolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                 [[UIBarButtonItem alloc] initWithTitle:@"Move to Selected Index Path" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)]]];
        [self.toolbar.items[0] setEnabled:NO];
        [self.toolbar sizeToFit];
        [self addSubview:self.toolbar];

        self.pickerView = [[UIPickerView alloc] init];
        self.pickerView.delegate = self;

        CGRect pickerViewFrame = self.pickerView.frame;
        pickerViewFrame.origin = CGPointMake(0, self.toolbar.frame.size.height);
        self.pickerView.frame = pickerViewFrame;

        [self addSubview:self.pickerView];

        CGRect selfFrame = frame;
        selfFrame.size.width = [UIScreen mainScreen].applicationFrame.size.width;
        selfFrame.size.height = self.pickerView.frame.size.height + self.toolbar.frame.size.height;
        self.frame = selfFrame;
    }
    return self;
}

- (void)doneButtonPressed:(UIBarButtonItem *)item
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.pickerView selectedRowInComponent:1] inSection:[self.pickerView selectedRowInComponent:0]];
    [self.delegate indexPathPickerView:self didSelectIndexPath:indexPath];
}

#pragma mark - <UIPickerViewDataSource>

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // Index path section and item.
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.delegate numberOfSectionsForIndexPathPickerView:self];
    } else if (component == 1) {
        NSInteger selectedSectionIndex = [pickerView selectedRowInComponent:0];
        return [self.delegate indexPathPickerView:self numberOfItemsInSection:selectedSectionIndex];
    } else {
        return 0;
    }
}

#pragma mark - <UIPickerViewDelegate>

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [NSString stringWithFormat:@"%ld", (long)row];
    } else if (component == 1) {
        return [NSString stringWithFormat:@"%ld", (long)row];
    } else {
        return @"Invalid";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // If the user changes sections, refresh the component that displays the number of items.
    if (component == 0) {
        [pickerView reloadComponent:1];
    }
}

@end
