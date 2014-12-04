#import "MRCommand.h"
#import "MRAdView.h"
#import "MRAdViewDisplayController.h"
#import "MPAdDestinationDisplayAgent.h"

#define kParamValidURLString @"http://www.google.com"
#define ParamValidURL() [NSURL URLWithString:kParamValidURLString]

#define kParamInvalidURLString @"http://www.google.com|||$$$++"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MRAdView () <MRCommandDelegate>

@property (nonatomic, assign) BOOL userTappedWebView;
@property (nonatomic, retain) MPAdDestinationDisplayAgent *destinationDisplayAgent;

@end

@interface MRCommand ()

+ (NSString *)commandType;

@end

SPEC_BEGIN(MRCommandSpec)

describe(@"MRCommand", ^{
    __block MRAdView *mrAdView;
    __block MRCommand *command;
    __block BOOL result;

    beforeEach(^{
        mrAdView = nice_fake_for([MRAdView class]);
    });

    it(@"should return the right Class for each command type", ^{
        MRCommand *command = [MRCommand commandForString:[MRExpandCommand commandType]];
        [command class] should equal([MRExpandCommand class]);

        command = [MRCommand commandForString:[MRCloseCommand commandType]];
        [command class] should equal([MRCloseCommand class]);

        command = [MRCommand commandForString:[MRUseCustomCloseCommand commandType]];
        [command class] should equal([MRUseCustomCloseCommand class]);

        command = [MRCommand commandForString:[MROpenCommand commandType]];
        [command class] should equal([MROpenCommand class]);

        command = [MRCommand commandForString:[MRCreateCalendarEventCommand commandType]];
        [command class] should equal([MRCreateCalendarEventCommand class]);

        command = [MRCommand commandForString:[MRPlayVideoCommand commandType]];
        [command class] should equal([MRPlayVideoCommand class]);

        command = [MRCommand commandForString:[MRStorePictureCommand commandType]];
        [command class] should equal([MRStorePictureCommand class]);
    });

    describe(@"MRExpandCommand", ^{
        __block NSDictionary *expandParams;

        context(@"execute", ^{
            beforeEach(^{
                command = [[MRExpandCommand alloc] init];
                command.delegate = mrAdView;

                NSDictionary *params = @{@"w":@"100", @"h":@"200", @"url":kParamValidURLString, @"shouldUseCustomClose":@"1", @"lockOrientation":@"0"};
                expandParams = @{@"expandToFrame":NSStringFromCGRect(CGRectMake(110, 150, 100, 200)), @"url":ParamValidURL(), @"useCustomClose":@YES, @"isModal":@NO, @"shouldLockOrientation":@NO};
                result = [command executeWithParams:params];
            });

            it(@"should call the delegate and return true", ^{
                mrAdView should have_received(@selector(mrCommand:expandWithParams:)).with(command).and_with(expandParams);
                result should be_truthy();
            });
        });

        context(@"execute with params missing a url", ^{
            beforeEach(^{
                command = [[MRExpandCommand alloc] init];
                command.delegate = mrAdView;

                NSDictionary *params = @{@"w":@"100", @"h":@"200", @"shouldUseCustomClose":@"1", @"lockOrientation":@"0"};
                expandParams = @{@"expandToFrame":NSStringFromCGRect(CGRectMake(110, 150, 100, 200)), @"url":[NSNull null], @"useCustomClose":@YES, @"isModal":@NO, @"shouldLockOrientation":@NO};
                result = [command executeWithParams:params];
            });

            it(@"should call the delegate and return true", ^{
                mrAdView should have_received(@selector(mrCommand:expandWithParams:)).with(command).and_with(expandParams);
                result should be_truthy();
            });
        });
    });

    describe(@"MRCloseCommand", ^{
        context(@"execute", ^{
            beforeEach(^{
                command = [[MRCloseCommand alloc] init];
                command.delegate = mrAdView;
                result = [command executeWithParams:[NSDictionary dictionary]];
            });

            it(@"should call the delegate and return true", ^{
                mrAdView should have_received(@selector(mrCommandClose:)).with(command);
                result should be_truthy();
            });
        });
    });

    describe(@"MRUseCustomCloseCommand", ^{
        context(@"execute", ^{
            beforeEach(^{
                command = [[MRUseCustomCloseCommand alloc] init];
                command.delegate = mrAdView;
                result = [command executeWithParams:@{@"shouldUseCustomClose" : @"1"}];
            });

            it(@"should call the delegate and return true", ^{
                mrAdView should have_received(@selector(mrCommand:shouldUseCustomClose:)).with(command).and_with(YES);
                result should be_truthy();
            });
        });
    });

    describe(@"MROpenCommand", ^{
        beforeEach(^{
            command = [[MROpenCommand alloc] init];
            command.delegate = mrAdView;
        });

        context(@"when executing a valid open url", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"url":kParamValidURLString}];
            });

            it(@"should call the delegate with a valid NSURL and return true", ^{
                mrAdView should have_received(@selector(mrCommand:openURL:)).with(command).and_with(ParamValidURL());
                result should be_truthy();
            });
        });

        context(@"when executing an open url with illegal characters", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"url":kParamInvalidURLString}];
            });

            it(@"should call the delegate with a nil NSURL and return true", ^{
                mrAdView should have_received(@selector(mrCommand:openURL:)).with(command).and_with(nil);
                result should be_truthy();
            });
        });
    });

    describe(@"MRPlayVideoCommand", ^{
        beforeEach(^{
            command = [[MRPlayVideoCommand alloc] init];
            command.delegate = mrAdView;
        });

        context(@"when executing a valid video uri", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"uri":kParamValidURLString}];
            });

            it(@"should tell the delegate to play the video with a valid NSURL and return true", ^{
                mrAdView should have_received(@selector(mrCommand:playVideoWithURL:)).with(command).and_with(ParamValidURL());
                result should be_truthy();
            });
        });

        context(@"when executing a video uri with illegal characters", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"uri":kParamInvalidURLString}];
            });

            it(@"should tell the delegate to play the video with a nil NSURL and return true", ^{
                mrAdView should have_received(@selector(mrCommand:playVideoWithURL:)).with(command).and_with(nil);
                result should be_truthy();
            });
        });
    });

    describe(@"MRStorePictureCommand", ^{
        beforeEach(^{
            command = [[MRStorePictureCommand alloc] init];
            command.delegate = mrAdView;
        });

        context(@"when executing a valid picture uri", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"uri":kParamValidURLString}];
            });

            it(@"should tell the delegate to store the picture with a valid NSURL and return true", ^{
                mrAdView should have_received(@selector(mrCommand:storePictureWithURL:)).with(command).and_with(ParamValidURL());
                result should be_truthy();
            });
        });

        context(@"when executing a picture uri with illegal characters", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"uri":kParamInvalidURLString}];
            });

            it(@"should tell the delegate to store the picture with a nil NSURL and return true", ^{
                mrAdView should have_received(@selector(mrCommand:storePictureWithURL:)).with(command).and_with(nil);
                result should be_truthy();
            });
        });
    });

    describe(@"MRCreateCalendarEventCommand", ^{
        context(@"execute", ^{
            __block NSDictionary *params;

            beforeEach(^{
                command = [[MRCreateCalendarEventCommand alloc] init];
                command.delegate = mrAdView;

                params = @{@"key1":@"value1", @"key2":@"value2"};
                result = [command executeWithParams:params];
            });

            it(@"should call the delegate and return true", ^{
                mrAdView should have_received(@selector(mrCommand:createCalendarEventWithParams:)).with(command).and_with(params);
                result should be_truthy();
            });
        });
    });
});

SPEC_END
