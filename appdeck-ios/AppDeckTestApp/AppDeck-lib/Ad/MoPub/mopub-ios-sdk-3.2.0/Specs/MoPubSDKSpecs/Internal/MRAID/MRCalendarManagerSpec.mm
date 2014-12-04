#import "MRCalendarManager.h"
#import <EventKit/EventKit.h>
#import "FakeEKEventStore.h"
#import "CedarAsync.h"

@interface MRCalendarManager (Spec)

// Exposed for testing.
@property (nonatomic, retain) EKEventEditViewController *eventEditViewController;

- (EKEvent *)calendarEventWithParameters:(NSDictionary *)parameters
                              eventStore:(EKEventStore *)eventStore;
- (EKRecurrenceRule *)recurrenceRuleWithParameters:(NSDictionary *)parameters;
- (void)presentCalendarEditor:(EKEventEditViewController *)editor;

@end

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MRCalendarManagerSpec)

describe(@"MRCalendarManager", ^{
    __block MRCalendarManager *manager;
    __block id<MRCalendarManagerDelegate> delegate;
    __block FakeEKEventStore *fakeEventStore;
    __block UIViewController *presentingViewController;
    __block EKEventEditViewController *eventEditViewController;

    beforeEach(^{
        fakeEventStore = [[FakeEKEventStore alloc] init];
        fakeProvider.fakeEKEventStore = fakeEventStore;

        eventEditViewController = [[EKEventEditViewController alloc] init];
        eventEditViewController.eventStore = fakeEventStore;
        fakeProvider.fakeEKEventEditViewController = eventEditViewController;

        delegate = nice_fake_for(@protocol(MRCalendarManagerDelegate));

        presentingViewController = [[UIViewController alloc] init];
        delegate stub_method("viewControllerForPresentingCalendarEditor").and_return(presentingViewController);

        manager = [[MRCalendarManager alloc] initWithDelegate:delegate];
    });

    afterEach(^{
        manager.delegate = nil;
    });

    describe(@"-createCalendarEventWithParameters:", ^{
        __block NSDictionary *calendarEventParameters;

        beforeEach(^{
            calendarEventParameters = @{
                                        @"description" : @"My Terrific Event",
                                        @"start": @"2013-07-19T17:00:00-07:00",
                                        @"end": @"2013-07-19T18:00:00-07:00"
                                        };
            [manager createCalendarEventWithParameters:calendarEventParameters];
        });

        context(@"when the user allows access to calendar", ^{
            beforeEach(^{
                [fakeEventStore simulateGrantingAccess];
            });

            it(@"should present a calendar event editor controller", ^{
                in_time(presentingViewController.presentedViewController) should be_same_instance_as(eventEditViewController);
            });

            context(@"when the user taps on the 'Done' button", ^{
                subjectAction(^{
                    [manager eventEditViewController:eventEditViewController didCompleteWithAction:EKEventEditViewActionSaved];
                });

                context(@"if the event can be saved", ^{
                    beforeEach(^{
                        fakeEventStore.shouldFailToSaveEvent = NO;
                    });

                    it(@"should save the new event to the calendar", ^{
                        EKEvent *expectedEvent = eventEditViewController.event;
                        expectedEvent.title should equal(@"My Terrific Event");
                        [expectedEvent.startDate description] should equal(@"2013-07-20 00:00:00 +0000");
                        [expectedEvent.endDate description] should equal(@"2013-07-20 01:00:00 +0000");
                        fakeEventStore.lastSavedEvent should be_same_instance_as(expectedEvent);
                    });
                });

                context(@"if the event cannot be saved", ^{
                    beforeEach(^{
                        fakeEventStore.shouldFailToSaveEvent = YES;
                    });

                    it(@"should inform its delegate that an error occurred", ^{
                        delegate should have_received(@selector(calendarManager:didFailToCreateCalendarEventWithErrorMessage:)).with(manager).and_with(Arguments::anything);
                    });
                });

                it(@"should dismiss the editor controller", ^{
                    presentingViewController.presentedViewController should be_nil;
                });
            });

            context(@"when the user taps on the 'Cancel' button", ^{
                beforeEach(^{
                    [manager eventEditViewController:eventEditViewController didCompleteWithAction:EKEventEditViewActionCanceled];
                });

                it(@"should not save the new event to the calendar", ^{
                    fakeEventStore.lastSavedEvent should be_nil;
                });

                it(@"should inform its delegate that an error occurred", ^{
                    delegate should have_received(@selector(calendarManager:didFailToCreateCalendarEventWithErrorMessage:)).with(manager).and_with(Arguments::anything);
                });

                it(@"should dismiss the editor controller", ^{
                    presentingViewController.presentedViewController should be_nil;
                });
            });
        });

        context(@"when the user denies access to calendar", ^{
            beforeEach(^{
                [fakeEventStore simulateDenyingAccess];
            });

            it(@"should not present a calendar event editor controller", ^{
                in_time(presentingViewController.presentedViewController) should be_nil;
            });

            it(@"should inform its delegate that an error occurred", ^{
                in_time(delegate) should have_received(@selector(calendarManager:didFailToCreateCalendarEventWithErrorMessage:)).with(manager).and_with(Arguments::anything);
            });
        });
    });

    describe(@"-calendarEventWithParameters:", ^{
        __block EKEvent *event;

        it(@"creates an event correctly", ^{
            event = [manager calendarEventWithParameters:@{@"description" : @"test", @"location": @"Texas", @"summary": @"yee-haw"}
                                              eventStore:nice_fake_for([EKEventStore class])];

            event.title should equal(@"test");
            event.location should equal(@"Texas");
            event.notes should equal(@"yee-haw");
            event.startDate should be_nil;
            event.endDate should be_nil;
        });

        it(@"should allow events with only a start date but no end date", ^{
            event = [manager calendarEventWithParameters:@{@"start" : @"2013-07-14T17:00:00-07:00"}
                                              eventStore:nil];

            [event.startDate description] should equal(@"2013-07-15 00:00:00 +0000");
            [event.startDate timeIntervalSince1970] should equal(1373846400);
            event.endDate should be_nil;
        });

        it(@"should create the correct start date for 2013-07-14T17:00-07:00", ^{
            event = [manager calendarEventWithParameters:@{@"start" : @"2013-07-14T17:00-07:00"}
                                              eventStore:nil];

            [event.startDate description] should equal(@"2013-07-15 00:00:00 +0000");
            [event.startDate timeIntervalSince1970] should equal(1373846400);
            event.endDate should be_nil;
        });

        it(@"should create the correct start date for 2013-07-15T7:00:00+07:00", ^{
            event = [manager calendarEventWithParameters:@{@"start" : @"2013-07-15T7:00:00+07:00"}
                                              eventStore:nil];

            [event.startDate description] should equal(@"2013-07-15 00:00:00 +0000");
            [event.startDate timeIntervalSince1970] should equal(1373846400);
            event.endDate should be_nil;
        });

        it(@"should fail to parse a start date for 2013 07 15T7:00:00+07", PENDING/*^{
            // This successfully parses under iOS 8 beta 4
            event = [manager calendarEventWithParameters:@{@"start" : @"2013 07 15T7:00:00+07"}
                                              eventStore:nil];

            [event.startDate timeIntervalSinceReferenceDate] should equal(0);
            event.endDate should be_nil;
        }*/);

        it(@"should fail to parse a start date for 2013abc0sdfd15T7:00:00+07", ^{
            event = [manager calendarEventWithParameters:@{@"start" : @"2013abc0sdfd15T7:00:00+07"}
                                              eventStore:nil];

            [event.startDate timeIntervalSinceReferenceDate] should equal(0);
            event.endDate should be_nil;
        });

        it(@"should create an event with an attached alarm if 'absoluteReminder' is set", ^{
            event = [manager calendarEventWithParameters:@{@"start" : @"2013-07-14T17:00:00-07:00", @"absoluteReminder": @"2013-07-19T16:50:00-07:00"}
                                              eventStore:nil];
            [event.startDate description] should equal(@"2013-07-15 00:00:00 +0000");
            [event.alarms count] should equal(1);
            [(EKAlarm *) event.alarms[0] absoluteDate] should equal([NSDate dateWithTimeIntervalSince1970:1374277800]);
            [[(EKAlarm *) event.alarms[0] absoluteDate] description] should equal(@"2013-07-19 23:50:00 +0000");
        });

        it(@"should create an event with an attached alarm if 'relativeReminder' is set", ^{
            event = [manager calendarEventWithParameters:@{@"start" : @"2013-07-14T17:00:00-07:00", @"relativeReminder": @"-600"}
                                              eventStore:nil];
            [event.startDate description] should equal(@"2013-07-15 00:00:00 +0000");
            [event.alarms count] should equal(1);
            [(EKAlarm *) event.alarms[0] relativeOffset] should equal(-600);
        });

        it(@"should create an event with a recurrence rule if there is a recurrence interval and frequency", ^{
            event = [manager calendarEventWithParameters:@{@"frequency": @"daily", @"interval": @"1"}
                                              eventStore:nil];
            [event.recurrenceRules count] should equal(1);
            [(EKRecurrenceRule *) event.recurrenceRules[0] frequency] should equal(EKRecurrenceFrequencyDaily);
            [(EKRecurrenceRule *) event.recurrenceRules[0] interval] should equal(1);
        });

        // XXX: These tests can't pass in the simulator because its calendar doesn't support any availability settings.
#if !TARGET_IPHONE_SIMULATOR
        it(@"should create an event with a busy availability setting if 'transparency' is set to 'opaque'", ^{
            event = [manager calendarEventWithParameters:@{@"transparency": @"opaque"}
                                              eventStore:nil];
            event.availability should equal(EKEventAvailabilityBusy);
        });

        it(@"should create an event with a free availability setting if 'transparency' is set to 'transparent'", ^{
            event = [manager calendarEventWithParameters:@{@"transparency": @"transparent"}
                                              eventStore:nil];
            event.availability should equal(EKEventAvailabilityFree);
        });
#endif
    });

    describe(@"-createRecurrenceRuleWithParameters:", ^{
        __block NSDictionary *parameters;
        __block EKRecurrenceRule *rule;

        subjectAction(^{
            rule = [manager recurrenceRuleWithParameters:parameters];
        });

        context(@"when the parameters describe a simple recurrence rule (frequency, interval, end)", ^{
            beforeEach(^{
                parameters = @{@"interval": @"1",
                               @"frequency": @"daily",
                               @"expires": @"1577865600"};
            });

            it(@"creates the rule correctly", ^{
                rule.interval should equal(1);
                rule.frequency should equal(EKRecurrenceFrequencyDaily);
                [rule.recurrenceEnd.endDate timeIntervalSince1970] should equal(1577865600);
            });

            describe(@"when the frequency is weekly", ^{
                beforeEach(^{
                    parameters = @{@"interval": @"1", @"frequency": @"weekly"};
                });

                it(@"creates the rule correctly", ^{
                    rule.frequency should equal(EKRecurrenceFrequencyWeekly);
                });
            });

            describe(@"when the frequency is monthly", ^{
                beforeEach(^{
                    parameters = @{@"interval": @"1", @"frequency": @"monthly"};
                });

                it(@"creates the rule correctly", ^{
                    rule.frequency should equal(EKRecurrenceFrequencyMonthly);
                });
            });

            describe(@"when the frequency is yearly", ^{
                beforeEach(^{
                    parameters = @{@"interval": @"1", @"frequency": @"yearly"};;
                });

                it(@"creates the rule correctly", ^{
                    rule.frequency should equal(EKRecurrenceFrequencyYearly);
                });
            });

            describe(@"when a recurrence end date is not provided", ^{
                beforeEach(^{
                    parameters = @{@"interval": @"1", @"frequency": @"yearly"};;
                });

                it(@"creates the rule correctly", ^{
                    rule.recurrenceEnd should be_nil;
                });
            });
        });

        context(@"when the parameters describe a recurrence rule with non-numerical days of the week", ^{
            beforeEach(^{
                parameters = @{@"interval": @"1", @"daysInWeek": @"totally invalid"};
            });

            // XXX: Although the mopub SDK will NOT blow up if it gets a nonsense value for a string
            //      representation of an array, the caller will get strange results back (i.e. Sunday
            //      for "totally invalid")
            it(@"creates the rule *correctly*", ^{
                // SDK will turn the invalid value into Sunday, avoiding this odd result would
                // mean more ugly code in the SDK
                EKRecurrenceDayOfWeek *sunday = [EKRecurrenceDayOfWeek dayOfWeek:1];
                rule.daysOfTheWeek should equal(@[sunday]);
            });
        });

        context(@"when the parameters describe a recurrence rule with numerical but invalid days of the week", ^{
            beforeEach(^{
                parameters = @{@"interval": @"1", @"daysInWeek": @"9"};
            });

            // XXX: When the value passed in is a number but invalid, the rule should ignore it
            it(@"creates the rule *correctly*", ^{
                [rule.daysOfTheWeek count] should equal(0);
            });
        });

        context(@"when the parameters describe a recurrence rule with valid days of the week", ^{
            beforeEach(^{
                // MRAID specifies 0 - 6, Sunday - Saturday
                parameters = @{@"interval": @"1", @"daysInWeek": @"0,1,2,3,4,5,6"};
            });

            it(@"creates the rule correctly", ^{
                // SDK requires 1 - 7, Sunday - Saturday
                EKRecurrenceDayOfWeek *sunday    = [EKRecurrenceDayOfWeek dayOfWeek:1];
                EKRecurrenceDayOfWeek *monday    = [EKRecurrenceDayOfWeek dayOfWeek:2];
                EKRecurrenceDayOfWeek *tuesday   = [EKRecurrenceDayOfWeek dayOfWeek:3];
                EKRecurrenceDayOfWeek *wednesday = [EKRecurrenceDayOfWeek dayOfWeek:4];
                EKRecurrenceDayOfWeek *thursday  = [EKRecurrenceDayOfWeek dayOfWeek:5];
                EKRecurrenceDayOfWeek *friday    = [EKRecurrenceDayOfWeek dayOfWeek:6];
                EKRecurrenceDayOfWeek *saturday  = [EKRecurrenceDayOfWeek dayOfWeek:7];

                rule.daysOfTheWeek should equal(@[sunday, monday, tuesday, wednesday, thursday, friday, saturday]);
            });
        });

        context(@"when the parameters describe a recurrence rule with days of the month", ^{
            beforeEach(^{
                // MRAID specifies [1..31] number of days from the first day of month
                // and [0..30] number of days before the last day of the month
                parameters = @{@"interval": @"1",
                               @"daysInMonth": @"-30,-15,-1,0,1,2,16,31"};
            });

            it(@"creates the rule correctly", ^{
                // SDK requires [-31..31] with positive numbers being days of the month starting
                // with first day and negative numbers being days of the month starting with last
                // day
                rule.daysOfTheMonth should equal(@[@-31,@-16,@-2,@-1,@1,@2,@16,@31]);
            });
        });

        context(@"when the parameters describe a recurrence rule with days of the year", ^{
            // XXX: SDK allows for calcuations that include leapyear - MRAID does not!

            beforeEach(^{
                // MRAID specifies [1..365] number of days from the first day of the year
                // and [0..-364] number of days before the last day of the year
                parameters = @{@"interval": @"1",
                               @"daysInYear": @"-364,-199,-99,-49,0,1,50,100,200,365"};
            });

            it(@"creates the rule correctly", ^{
                // SDK requires [-366..366] non zero values with positive numbers being days of the
                // year starting with the first day and negative numbers being days of the month
                // counting backward from the end of the year
                rule.daysOfTheYear should equal(@[@-365,@-200,@-100,@-50,@-1,@1,@50,@100,@200,@365]);
            });
        });

        context(@"when the parameters describe a recurrence rule with months of the year", ^{
            beforeEach(^{
                // MRAID specifies 1 - 12, January - December
                parameters = @{@"interval": @"1",
                               @"monthsInYear": @"1,2,3,4,5,6,7,8,9,10,11,12"};
            });

            it(@"creates the rule correctly", ^{
                // MRAID requires 1 - 12, January - December
                rule.monthsOfTheYear should equal(@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12]);
            });
        });
    });

    describe(@"-dealloc", ^{
        context(@"while the EventKit controller is showing", ^{
            __block MRCalendarManager *anotherManager;

            beforeEach(^{
                anotherManager = [[MRCalendarManager alloc] initWithDelegate:delegate];
                anotherManager.eventEditViewController = eventEditViewController;

                [manager presentCalendarEditor:eventEditViewController];
                presentingViewController.presentedViewController should equal(eventEditViewController);
                anotherManager = nil;
            });

            it(@"should still allow the controller to be dismissed later", ^{
                [eventEditViewController.editViewDelegate eventEditViewController:eventEditViewController didCompleteWithAction:EKEventEditViewActionCanceled];
                presentingViewController.presentedViewController should be_nil;
            });
        });
    });
});

SPEC_END
