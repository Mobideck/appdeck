//
//  CustomDatePicker.m
//  AppDeck
//
//  Created by hanine ben saad on 19/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "CustomDatePicker.h"
#import "YearMonthPickerView.h"


@interface CustomDatePicker ()

@property (copy) void (^onSelectCompletion)(NSString *);



@end

@implementation CustomDatePicker


+ (CustomDatePicker*)sharedView {
    static dispatch_once_t once;
    static CustomDatePicker *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] init]; });
    return sharedView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+(void)PresentInVC:(UIViewController*)vc fromCall:(AppDeckApiCall*)call completion:(void(^)(NSString *selectedString))completion{
    
    id year = [call.param objectForKey:@"year"];
    id month = [call.param objectForKey:@"month"];
    id day = [call.param objectForKey:@"day"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
   __block NSDateComponents *components = [[NSDateComponents alloc] init];
    
    if (day != nil && day != [NSNull null])
        [components setDay:[day intValue]];
    if (month != nil && month != [NSNull null])
        [components setMonth:[month intValue]];
    if (year != nil&& year != [NSNull null])
        [components setYear:[year intValue]];
    
    NSDate *date = [calendar dateFromComponents:components];
    
//    CustomDatePicker*controller =[[CustomDatePicker alloc] init];
//    [controller setTitle:@"AppDeck \n\n\n\n\n\n"];
//
     CustomDatePicker*controller =   [CustomDatePicker alertControllerWithTitle:@"AppDeck \n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (![day isKindOfClass:[NSNull class]]) {
        
        UIDatePicker*datePicker =  [controller initializeDatepickerWitDate:date];
        [controller addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:datePicker.date];
            [call performSelectorOnMainThread:@selector(sendCallbackWithResult:) withObject:@[@{@"year": [NSNumber numberWithInteger:[components year]], @"month" : [NSNumber numberWithInteger:[components month]], @"day" : [NSNumber numberWithInteger:[components day]]}] waitUntilDone:NO];
            //[call sendCallbackWithResult:@[@{@"year": [NSNumber numberWithInteger:[components year]], @"month" : [NSNumber numberWithInteger:[components month]], @"day" : [NSNumber numberWithInteger:[components day]]}]];
            
        }]];
        
        [controller.view addSubview:datePicker];
    }else{
        YearMonthPickerView*pickerView=[[YearMonthPickerView alloc]initPickerviewWithFrame:CGRectMake(0, 20, 320, 120) andDateComponents:components];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            
//            NSLog(@"month %d",[pickerView selectedRowInComponent:0]);
//            NSLog(@"year %d",[pickerView selectedRowInComponent:1]);

//            components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:datePicker.date];
//            [call performSelectorOnMainThread:@selector(sendCallbackWithResult:) withObject:@[@{@"year": [NSNumber numberWithInteger:[components year]], @"month" : [NSNumber numberWithInteger:[components month]], @"day" : [NSNumber numberWithInteger:[components day]]}] waitUntilDone:NO];
         // [call sendCallbackWithResult:@[@{@"year": [NSNumber numberWithInteger:[pickerView selectedRowInComponent:1]], @"month" : [NSNumber numberWithInteger:[pickerView selectedRowInComponent:0]+1]}]];
             [call performSelectorOnMainThread:@selector(sendCallbackWithResult:) withObject:@[@{@"year": [NSNumber numberWithInteger:[pickerView selectedRowInComponent:1]], @"month" : [NSNumber numberWithInteger:[pickerView selectedRowInComponent:0]+1]}] waitUntilDone:NO];
        }]];
        
         [controller.view addSubview:pickerView];
    }
    
    [vc presentViewController:controller animated:YES completion:nil];
    
}

-(UIDatePicker*)initializeDatepickerWitDate:(NSDate*)date{
    UIDatePicker*datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 20, 320, 120)];
    datePicker.date = date;
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(selectDate) forControlEvents:UIControlEventValueChanged];
    
    return datePicker;
}

-(UIPickerView*)initializePickerViewWithDate:(NSDate*)date{
    
}

+(void)SelectWithCompletion:(void (^)(NSString *))completion{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
