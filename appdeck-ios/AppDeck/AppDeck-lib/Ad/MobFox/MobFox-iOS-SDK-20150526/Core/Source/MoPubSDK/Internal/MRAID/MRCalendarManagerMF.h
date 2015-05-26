//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKitUI/EventKitUI.h>

@protocol MRCalendarManagerDelegateMF;

@interface MRCalendarManagerMF : NSObject <EKEventEditViewDelegate>

@property (nonatomic, assign) NSObject<MRCalendarManagerDelegateMF> *delegate;

- (id)initWithDelegate:(NSObject<MRCalendarManagerDelegateMF> *)delegate;
- (void)createCalendarEventWithParameters:(NSDictionary *)parameters;

@end

@protocol MRCalendarManagerDelegateMF <NSObject>

@required
- (UIViewController *)viewControllerForPresentingCalendarEditor;
- (void)calendarManagerWillPresentCalendarEditor:(MRCalendarManagerMF *)manager;
- (void)calendarManagerDidDismissCalendarEditor:(MRCalendarManagerMF *)manager;
- (void)calendarManager:(MRCalendarManagerMF *)manager
        didFailToCreateCalendarEventWithErrorMessage:(NSString *)message;

@end
