#import "MPGlobal.h"
#import "UIView+MPSpecs.h"
#import "MPGlobalSpecHelper.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPGlobalSpec)

describe(@"MPGlobal", ^{
    it(@"should test the full suite of functionality", PENDING);

    describe(@"MPTelephoneConfirmationController", ^{
        context(@"initialization", ^{
            it(@"should return nil for non telephone URLs", ^{
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"http://www.zombo.com"] clickHandler:nil] should be_nil;
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"twitter://idontknow"] clickHandler:nil] should be_nil;
            });

            it(@"should return nil for tel: and telPrompt: URLs with no number", ^{
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"tel:"] clickHandler:nil] should be_nil;
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"telprompt:"] clickHandler:nil] should be_nil;
            });

            it(@"should initialize for tel scheme URLs", ^{
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"tel://3439899999"] clickHandler:nil] should_not be_nil;
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"tel:3439899999"] clickHandler:nil] should_not be_nil;
            });

            it(@"should initialize for telprompt scheme URLs", ^{
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"telprompt://3439899999"] clickHandler:nil] should_not be_nil;
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"telprompt:3439899999"] clickHandler:nil] should_not be_nil;
            });
        });
    });

    describe(@"MPScreenResolution", ^{
        it(@"should return the resolution of the screen", ^{
            CGSize screenSizeInPoints = [MPGlobalSpecHelper screenBounds].size;
            CGFloat scale = [MPGlobalSpecHelper deviceScaleFactor];
            CGSize screenResolution = [MPGlobalSpecHelper screenResolution];

            screenResolution.width should equal(screenSizeInPoints.width*scale);
            screenResolution.height should equal(screenSizeInPoints.height*scale);
        });
    });

    describe(@"MPViewIsVisible", ^{
        __block UIWindow *keyWindow;
        __block UIView *testView;

        beforeEach(^{
            keyWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [keyWindow makeKeyAndVisible];

            testView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, 100, 100)];
            testView.hidden = NO;
        });

        it(@"should return false when the view is hidden", ^{
            testView.hidden = YES;
            [keyWindow addSubview:testView];
            [testView mp_viewIsVisible] should be_falsy;
        });

        it(@"should return false if the view is not part of a window", ^{
            [testView removeFromSuperview];
            [testView mp_viewIsVisible] should be_falsy;
        });

        context(@"when the view is within the key window's hierarchy", ^{
            __block UIView *ancestor;

            beforeEach(^{
                ancestor = [[UIView alloc] init];
                ancestor.frame = CGRectMake(0, 0, 10, 10);
                [ancestor addSubview:testView];
                [keyWindow addSubview:ancestor];
            });

            it(@"should return false if the view has a hidden ancestor", ^{
                // Make the testView intersect the parent window.
                testView.frame = CGRectMake(0, 0, 4, 4);

                ancestor.hidden = YES;
                [ancestor addSubview:testView];
                [keyWindow addSubview:ancestor];

                [testView mp_viewIsVisible] should be_falsy;
            });

            context(@"when the view has no hidden ancestors", ^{
                beforeEach(^{
                    ancestor.hidden = NO;
                });

                it(@"should return true if the parent window intersects the view", ^{
                    testView.frame = CGRectMake(99, 99, 10, 10);
                    [testView mp_viewIsVisible] should be_truthy;
                });

                it(@"should return false if the view doesn't intersect the window", ^{
                    testView.frame = CGRectMake(101, 101, 10, 10);
                    [testView mp_viewIsVisible] should be_falsy;
                });
            });
        });
    });

    describe(@"MPViewIntersectsParentWindowWithPercent", ^{
        __block UIWindow *keyWindow;
        __block UIView *testView;

        beforeEach(^{
            keyWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [keyWindow makeKeyAndVisible];
        });

        context(@"Y-axis", ^{
            context(@"when a view's intersection area is greater than the percent required", ^{
                beforeEach(^{
                    testView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, 100, 100)];
                    [keyWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsParentWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is equal to the percent required", ^{
                beforeEach(^{
                    testView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 100, 100)];
                    [keyWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsParentWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is less than the percent required", ^{
                beforeEach(^{
                    testView = [[UIView alloc] initWithFrame:CGRectMake(0, 51, 100, 100)];
                    [keyWindow addSubview:testView];
                });

                it(@"should return NO", ^{
                    [testView mp_viewIntersectsParentWindowWithPercent:0.5f] should equal(NO);
                });
            });
        });

        context(@"X-axis", ^{
            context(@"when a view's intersection area is greater than the percent required", ^{
                beforeEach(^{
                    testView = [[UIView alloc] initWithFrame:CGRectMake(49, 0, 100, 100)];
                    [keyWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsParentWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is equal to the percent required", ^{
                beforeEach(^{
                    testView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 100, 100)];
                    [keyWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsParentWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is less than the percent required", ^{
                beforeEach(^{
                    testView = [[UIView alloc] initWithFrame:CGRectMake(51, 0, 100, 100)];
                    [keyWindow addSubview:testView];
                });

                it(@"should return NO", ^{
                    [testView mp_viewIntersectsParentWindowWithPercent:0.5f] should equal(NO);
                });
            });
        });

        context(@"Both axes", ^{
            context(@"when a view's intersection area is greater than the percent required", ^{
                beforeEach(^{
                    testView = [[UIView alloc] initWithFrame:CGRectMake(29, 29, 100, 100)];
                    [keyWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsParentWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is less than the percent required", ^{
                beforeEach(^{
                    testView = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 100, 100)];
                    [keyWindow addSubview:testView];
                });

                it(@"should return NO", ^{
                    [testView mp_viewIntersectsParentWindowWithPercent:0.5f] should equal(NO);
                });
            });
        });

        context(@"Moving the same view around", ^{
            beforeEach(^{
                testView = [[UIView alloc] initWithFrame:CGRectZero];
                [keyWindow addSubview:testView];
            });

            it(@"should return the correct result", ^{
                testView.frame = CGRectMake(29, 29, 100, 100);
                [testView mp_viewIntersectsParentWindowWithPercent:0.5f] should equal(YES);

                testView.frame = CGRectMake(30, 30, 100, 100);
                [testView mp_viewIntersectsParentWindowWithPercent:0.5f] should equal(NO);
            });
        });
    });

    describe(@"MPConvertStringArrayToURLArray", ^{
        it(@"should only process array elements that are valid URL strings", ^{
            NSArray *arrayOfDifferentStuff = @[@"http://www.google.com",
                                               @1,
                                              [NSNull null],
                                              @(9.9f),
                                               @[@"http://www.google.com"],
                                               @{ @"lol" : @"http://www.twitter.com" },
                                               @"http://www.twitter.com",
                                               @"+_{}||@$%"];
            NSArray *processedArray = [MPGlobalSpecHelper convertStrArrayToURLArray:arrayOfDifferentStuff];

            NSURL *url1 = (NSURL *)processedArray[0];
            NSURL *url2 = (NSURL *)processedArray[1];

            url1.absoluteString should equal(@"http://www.google.com");
            url2.absoluteString should equal(@"http://www.twitter.com");
            processedArray.count should equal(2);
        });
    });

    describe(@"UIApplication", ^{
        describe(@"mp_supportsOrientationMask:", ^{
            __block NSDictionary *orientations;
            __block NSString *orientationKey;
            __block NSBundle *mainBundle;

            beforeEach(^{
                orientationKey = @"UISupportedInterfaceOrientations";
                mainBundle = [NSBundle mainBundle];
                spy_on(mainBundle);
            });

            context(@"when the app supports landscape left", ^{
                beforeEach(^{
                    orientations = @{orientationKey : @[@"UIInterfaceOrientationLandscapeLeft"]};
                    mainBundle stub_method(@selector(infoDictionary)).and_return(orientations);
                });

                it(@"should support landscape", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscape] should be_truthy;
                });

                it(@"should support landscape left", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscapeLeft] should be_truthy;
                });

                it(@"should not support landscape right", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscapeRight] should be_falsy;
                });

                it(@"should not support portraits", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskPortrait] should be_falsy;
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskPortraitUpsideDown] should be_falsy;
                });
            });

            context(@"when the app supports landscape right", ^{
                beforeEach(^{
                    orientations = @{orientationKey : @[@"UIInterfaceOrientationLandscapeRight"]};
                    mainBundle stub_method(@selector(infoDictionary)).and_return(orientations);
                });

                it(@"should support landscape", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscape] should be_truthy;
                });

                it(@"should not support landscape left", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscapeLeft] should be_falsy;
                });

                it(@"should support landscape right", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscapeRight] should be_truthy;
                });

                it(@"should not support portraits", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskPortrait] should be_falsy;
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskPortraitUpsideDown] should be_falsy;
                });
            });

            context(@"when the app supports portrait", ^{
                beforeEach(^{
                    orientations = @{orientationKey : @[@"UIInterfaceOrientationPortrait"]};
                    mainBundle stub_method(@selector(infoDictionary)).and_return(orientations);
                });

                it(@"should not support landscape", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscape] should be_falsy;
                });

                it(@"should not support landscape left", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscapeLeft] should be_falsy;
                });

                it(@"should not support landscape right", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscapeRight] should be_falsy;
                });

                it(@"should support portrait", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskPortrait] should be_truthy;
                });

                it(@"should not support portrait upside down", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskPortraitUpsideDown] should be_falsy;
                });
            });

            context(@"when the app supports portrait upside down", ^{
                beforeEach(^{
                    orientations = @{orientationKey : @[@"UIInterfaceOrientationPortraitUpsideDown"]};
                    mainBundle stub_method(@selector(infoDictionary)).and_return(orientations);
                });

                it(@"should not support landscape", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscape] should be_falsy;
                });

                it(@"should not support landscape left", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscapeLeft] should be_falsy;
                });

                it(@"should not support landscape right", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskLandscapeRight] should be_falsy;
                });

                it(@"should not support portrait", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskPortrait] should be_falsy;
                });

                it(@"should support portrait upside down", ^{
                    [[UIApplication sharedApplication] mp_supportsOrientationMask:UIInterfaceOrientationMaskPortraitUpsideDown] should be_truthy;
                });
            });
        });

        describe(@"mp_doesOrientation:matchOrientationMask:", ^{
            __block UIInterfaceOrientation orientation;

            describe(@"portrait orientation", ^{
                beforeEach(^{
                    orientation = UIInterfaceOrientationPortrait;
                });

                it(@"should match portrait mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskPortrait] should be_truthy;
                });

                it(@"should not match upside down mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskPortraitUpsideDown] should be_falsy;
                });

                it(@"should not match landscape left mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscapeLeft] should be_falsy;
                });

                it(@"should not match landscape right mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscapeRight] should be_falsy;
                });

                it(@"should not match landscape mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscape] should be_falsy;
                });
            });

            describe(@"upside down orientation", ^{
                beforeEach(^{
                    orientation = UIInterfaceOrientationPortraitUpsideDown;
                });

                it(@"should not match portrait mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskPortrait] should be_falsy;
                });

                it(@"should match upside down mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskPortraitUpsideDown] should be_truthy;
                });

                it(@"should not match landscape left mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscapeLeft] should be_falsy;
                });

                it(@"should not match landscape right mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscapeRight] should be_falsy;
                });

                it(@"should not match landscape mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscape] should be_falsy;
                });
            });

            describe(@"landscape left", ^{
                beforeEach(^{
                    orientation = UIInterfaceOrientationLandscapeLeft;
                });

                it(@"should not match portrait mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskPortrait] should be_falsy;
                });

                it(@"should not match upside down mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskPortraitUpsideDown] should be_falsy;
                });

                it(@"should match landscape left mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscapeLeft] should be_truthy;
                });

                it(@"should not match landscape right mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscapeRight] should be_falsy;
                });

                it(@"should match landscape mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscape] should be_truthy;
                });
            });

            describe(@"landscape right", ^{
                beforeEach(^{
                    orientation = UIInterfaceOrientationLandscapeRight;
                });

                it(@"should not match portrait mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskPortrait] should be_falsy;
                });

                it(@"should not match upside down mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskPortraitUpsideDown] should be_falsy;
                });

                it(@"should not match landscape left mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscapeLeft] should be_falsy;
                });

                it(@"should match landscape right mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscapeRight] should be_truthy;
                });

                it(@"should match landscape mask", ^{
                    [[UIApplication sharedApplication] mp_doesOrientation:orientation matchOrientationMask:UIInterfaceOrientationMaskLandscape] should be_truthy;
                });
            });
        });
    });
});

SPEC_END
