#import "MRCommand.h"
#import "MRNativeCommandHandler+Specs.h"
#import <Cedar/Cedar.h>

#define kParamValidURLString @"http://www.google.com"
#define ParamValidURL() [NSURL URLWithString:kParamValidURLString]

#define kParamInvalidURLString @"http://www.google.com|||$$$++"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MRCommand ()

+ (NSString *)commandType;

@end

SPEC_BEGIN(MRCommandSpec)

describe(@"MRCommand", ^{
    __block MRNativeCommandHandler *nativeCommandHandler;
    __block MRCommand *command;
    __block BOOL result;

    beforeEach(^{
        nativeCommandHandler = nice_fake_for([MRNativeCommandHandler class]);
    });

    it(@"should return the right Class for each command type", ^{
        MRCommand *command = [MRCommand commandForString:[MRExpandCommand commandType]];
        [command class] should equal([MRExpandCommand class]);

        command = [MRCommand commandForString:[MRResizeCommand commandType]];
        [command class] should equal([MRResizeCommand class]);

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
                command.delegate = nativeCommandHandler;

                NSDictionary *params = @{@"url":kParamValidURLString, @"shouldUseCustomClose":@"1"};
                expandParams = @{@"url":ParamValidURL(), @"useCustomClose":@YES};
                result = [command executeWithParams:params];
            });

            it(@"should call the delegate and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:expandWithParams:)).with(command).and_with(expandParams);
                result should be_truthy();
            });
        });

        context(@"execute with params missing a url", ^{
            beforeEach(^{
                command = [[MRExpandCommand alloc] init];
                command.delegate = nativeCommandHandler;

                NSDictionary *params = @{@"shouldUseCustomClose":@"1"};
                expandParams = @{@"url":[NSNull null], @"useCustomClose":@YES};
                result = [command executeWithParams:params];
            });

            it(@"should call the delegate and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:expandWithParams:)).with(command).and_with(expandParams);
                result should be_truthy();
            });
        });
    });

    describe(@"MRResizeCommand", ^{
        __block NSDictionary *resizeParams;

        context(@"execute", ^{
            beforeEach(^{
                command = [[MRResizeCommand alloc] init];
                command.delegate = nativeCommandHandler;

                resizeParams = @{@"width":@(320), @"height":@(200), @"offsetX":@(0), @"offsetY":@(-150), @"allowOffscreen":@YES, @"customClosePosition":@"top-right"};
                result = [command executeWithParams:resizeParams];
            });

            it(@"should call the delegate and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:resizeWithParams:)).with(command).and_with(resizeParams);
                result should be_truthy();
            });
        });
    });

    describe(@"MRSetOrientationPropertiesCommand", ^{
        beforeEach(^{
            command = [[MRSetOrientationPropertiesCommand alloc] init];
            command.delegate = nativeCommandHandler;
        });

        context(@"when forcing an orientation that is portrait", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"allowOrientationChange" : @"true", @"forceOrientation" : @"portrait"}];
            });

            it(@"should disable allow change no matter what and force portrait orientation", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:setOrientationPropertiesWithForceOrientation:)).with(command).and_with(UIInterfaceOrientationMaskPortrait);
                result should be_truthy();
            });
        });

        context(@"when forcing an orientation that is landscape", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"allowOrientationChange" : @"true", @"forceOrientation" : @"landscape"}];
            });

            it(@"should disable allow change no matter what and force landscape orientation", ^{
                // We default to landscape left when the user isn't currently in landscape.
                nativeCommandHandler should have_received(@selector(mrCommand:setOrientationPropertiesWithForceOrientation:)).with(command).and_with(UIInterfaceOrientationMaskLandscape);
                result should be_truthy();
            });
        });

        context(@"when forcing an orientation that is none", ^{
            it(@"should pass down UIInterfaceOrientationMaskAll when allowing orientation change", ^{
                result = [command executeWithParams:@{@"allowOrientationChange" : @"true", @"forceOrientation" : @"none"}];
                nativeCommandHandler should have_received(@selector(mrCommand:setOrientationPropertiesWithForceOrientation:)).with(command).and_with(UIInterfaceOrientationMaskAll);
                result should be_truthy();
            });

            it(@"should pass down a mask matching the current orientation when not allowing orientation change", ^{
                result = [command executeWithParams:@{@"allowOrientationChange" : @"false", @"forceOrientation" : @"none"}];
                // Not the best test, but we're definitely starting out in portrait, so it should pass the portrait mask down.
                nativeCommandHandler should have_received(@selector(mrCommand:setOrientationPropertiesWithForceOrientation:)).with(command).and_with(UIInterfaceOrientationMaskPortrait);
                result should be_truthy();
            });
        });

        xcontext(@"when force orientation is not the same as the current orientation", ^{
            // When they're different, the force orientation will lock to landscape left (if force is landscape) or lock to portrait upright (if the force is portrait).
        });

        xcontext(@"when force orientation is the same as the current orientation", ^{
            // When they're the same, the force orientation will equal the current orientation which is what is happening in the portrait case above.
        });
    });

    describe(@"MRCloseCommand", ^{
        context(@"execute", ^{
            beforeEach(^{
                command = [[MRCloseCommand alloc] init];
                command.delegate = nativeCommandHandler;
                result = [command executeWithParams:[NSDictionary dictionary]];
            });

            it(@"should call the delegate and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommandClose:)).with(command);
                result should be_truthy();
            });
        });
    });

    describe(@"MRUseCustomCloseCommand", ^{
        context(@"execute", ^{
            beforeEach(^{
                command = [[MRUseCustomCloseCommand alloc] init];
                command.delegate = nativeCommandHandler;
                result = [command executeWithParams:@{@"shouldUseCustomClose" : @"1"}];
            });

            it(@"should call the delegate and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:shouldUseCustomClose:)).with(command).and_with(YES);
                result should be_truthy();
            });
        });
    });

    describe(@"MROpenCommand", ^{
        beforeEach(^{
            command = [[MROpenCommand alloc] init];
            command.delegate = nativeCommandHandler;
        });

        context(@"when executing a valid open url", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"url":kParamValidURLString}];
            });

            it(@"should call the delegate with a valid NSURL and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:openURL:)).with(command).and_with(ParamValidURL());
                result should be_truthy();
            });
        });

        context(@"when executing an open url with illegal characters", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"url":kParamInvalidURLString}];
            });

            it(@"should call the delegate with a nil NSURL and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:openURL:)).with(command).and_with(nil);
                result should be_truthy();
            });
        });
    });

    describe(@"MRPlayVideoCommand", ^{
        beforeEach(^{
            command = [[MRPlayVideoCommand alloc] init];
            command.delegate = nativeCommandHandler;
        });

        context(@"when executing a valid video uri", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"uri":kParamValidURLString}];
            });

            it(@"should tell the delegate to play the video with a valid NSURL and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:playVideoWithURL:)).with(command).and_with(ParamValidURL());
                result should be_truthy();
            });
        });

        context(@"when executing a video uri with illegal characters", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"uri":kParamInvalidURLString}];
            });

            it(@"should tell the delegate to play the video with a nil NSURL and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:playVideoWithURL:)).with(command).and_with(nil);
                result should be_truthy();
            });
        });
    });

    describe(@"MRStorePictureCommand", ^{
        beforeEach(^{
            command = [[MRStorePictureCommand alloc] init];
            command.delegate = nativeCommandHandler;
        });

        context(@"when executing a valid picture uri", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"uri":kParamValidURLString}];
            });

            it(@"should tell the delegate to store the picture with a valid NSURL and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:storePictureWithURL:)).with(command).and_with(ParamValidURL());
                result should be_truthy();
            });
        });

        context(@"when executing a picture uri with illegal characters", ^{
            beforeEach(^{
                result = [command executeWithParams:@{@"uri":kParamInvalidURLString}];
            });

            it(@"should tell the delegate to store the picture with a nil NSURL and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:storePictureWithURL:)).with(command).and_with(nil);
                result should be_truthy();
            });
        });
    });

    describe(@"MRCreateCalendarEventCommand", ^{
        context(@"execute", ^{
            __block NSDictionary *params;

            beforeEach(^{
                command = [[MRCreateCalendarEventCommand alloc] init];
                command.delegate = nativeCommandHandler;

                params = @{@"key1":@"value1", @"key2":@"value2"};
                result = [command executeWithParams:params];
            });

            it(@"should call the delegate and return true", ^{
                nativeCommandHandler should have_received(@selector(mrCommand:createCalendarEventWithParams:)).with(command).and_with(params);
                result should be_truthy();
            });
        });
    });
});

SPEC_END
