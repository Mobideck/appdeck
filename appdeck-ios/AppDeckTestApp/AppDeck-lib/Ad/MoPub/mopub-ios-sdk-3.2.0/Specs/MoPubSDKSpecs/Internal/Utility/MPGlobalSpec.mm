#import "MPGlobal.h"
#import "UIView+MPSpecs.h"

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
});

SPEC_END
