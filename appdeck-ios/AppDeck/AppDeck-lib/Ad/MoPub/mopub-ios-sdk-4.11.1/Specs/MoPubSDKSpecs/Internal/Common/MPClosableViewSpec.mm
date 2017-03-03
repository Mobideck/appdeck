#import "MPClosableView+MPSpecs.h"
#import "CedarAsync.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPClosableViewSpec)

static CGFloat const closeWidth = 50.0f;
static CGFloat const closeHeight = 50.0f;

describe(@"MPClosableView", ^{
    __block MPClosableView *closableView;
    __block CGRect viewFrame;

    beforeEach(^{
        viewFrame = CGRectMake(50.0f, 100.0f, 200.0f, 300.0f);
    });

    describe(@"Initialization", ^{
        beforeEach(^{
            closableView = [[MPClosableView alloc] initWithFrame:viewFrame closeButtonType:MPClosableViewCloseButtonTypeTappableWithImage];
        });

        it(@"should intialize its frame from the passed in frame", ^{
            closableView.frame should equal(viewFrame);
        });

//        it(@"should configure the close button correctly given the specified close button type", ^{
//            closableView.closeButtonType should equal(MPClosableViewCloseButtonTypeTappableWithImage);
//            [closableView.closeButton imageForState:UIControlStateNormal] should equal(closableView.closeButtonImage);
//            closableView.closeButton.hidden should be_falsy;
//
//            closableView = [[MPClosableView alloc] initWithFrame:viewFrame closeButtonType:MPClosableViewCloseButtonTypeTappableWithoutImage];
//            [closableView.closeButton imageForState:UIControlStateNormal] should equal(nil);
//            closableView.closeButton.hidden should be_falsy;
//
//            closableView = [[MPClosableView alloc] initWithFrame:viewFrame closeButtonType:MPClosableViewCloseButtonTypeNone];
//            closableView.closeButton.hidden should be_truthy;
//        });

        it(@"should not have been tapped", ^{
            closableView.wasTapped should be_falsy;
        });

        it(@"should locate the close button at the top right by default", ^{
            CGRect topRight = CGRectMake(viewFrame.size.width-closeWidth, 0.0f, closeWidth, closeHeight);
            [closableView layoutSubviews];
            closableView.closeButton.frame should equal(topRight);
        });
    });

    describe(@"When the view is tapped", ^{
        beforeEach(^{
            closableView = [[MPClosableView alloc] initWithFrame:viewFrame closeButtonType:MPClosableViewCloseButtonTypeTappableWithImage];
        });

        xit(@"should report the ad was tapped after it had actually been tapped", nil);
        xit(@"should report the ad was tapped to its delegate", nil);
    });

    describe(@"Adding a subview", ^{
        __block UIView *contentView;

        beforeEach(^{
            closableView = [[MPClosableView alloc] initWithFrame:viewFrame closeButtonType:MPClosableViewCloseButtonTypeTappableWithImage];
            spy_on(closableView);

            contentView = [[UIView alloc] init];
            [closableView addSubview:contentView];

            // Just go ahead and call layoutSubviews for testing purposes.
            [closableView layoutSubviews];
        });

        it(@"should contain the subview and the close button as sub views", ^{
            [closableView.subviews containsObject:contentView] should be_truthy;
            [closableView.subviews containsObject:closableView.closeButton] should be_truthy;
        });

        it(@"should bring the close button to the front of the closable view's view hierarchy", ^{
            closableView should have_received(@selector(bringSubviewToFront:)).with(closableView.closeButton);
            closableView.subviews.lastObject should equal(closableView.closeButton);
        });
    });

    describe(@"Setting close button type", ^{
        beforeEach(^{
            closableView = [[MPClosableView alloc] initWithFrame:viewFrame closeButtonType:MPClosableViewCloseButtonTypeTappableWithImage];
        });

//        it(@"should configure the close button correctly for the given close button type", ^{
//            closableView.closeButtonType = MPClosableViewCloseButtonTypeTappableWithoutImage;
//            [closableView.closeButton imageForState:UIControlStateNormal] should equal(nil);
//            closableView.closeButton.hidden should be_falsy;
//
//            closableView.closeButtonType = MPClosableViewCloseButtonTypeNone;
//            closableView.closeButton.hidden should be_truthy;
//
//            closableView.closeButtonType = MPClosableViewCloseButtonTypeTappableWithImage;
//            [closableView.closeButton imageForState:UIControlStateNormal] should equal(closableView.closeButtonImage);
//            closableView.closeButton.hidden should be_falsy;
//        });
    });

    describe(@"Setting close button location", ^{
        beforeEach(^{
            closableView = [[MPClosableView alloc] initWithFrame:viewFrame closeButtonType:MPClosableViewCloseButtonTypeTappableWithImage];
        });

        it(@"should call setNeedsLayout", ^{
            spy_on(closableView);

            closableView should_not have_received(@selector(setNeedsLayout));
            closableView.closeButtonLocation = MPClosableViewCloseButtonLocationTopLeft;
            closableView should have_received(@selector(setNeedsLayout));
        });

        it(@"should position the button at the top left of the view for location: MPClosableViewCloseButtonLocationTopLeft", ^{
            closableView.closeButtonLocation = MPClosableViewCloseButtonLocationTopLeft;
            [closableView layoutSubviews];
            CGRect frame = CGRectMake(0.0f, 0.0f, closeWidth, closeHeight);
            closableView.closeButton.frame should equal(frame);
        });

        it(@"should position the button at the top right of the view for location: MPClosableViewCloseButtonLocationTopRight", ^{
            // By default it's top right, so let's set the location to something else and set it back to top right.
            closableView.closeButtonLocation = MPClosableViewCloseButtonLocationTopLeft;
            [closableView layoutSubviews];
            closableView.closeButtonLocation = MPClosableViewCloseButtonLocationTopRight;
            [closableView layoutSubviews];
            CGRect frame = CGRectMake(viewFrame.size.width-closeWidth, 0.0f, closeWidth, closeHeight);
            closableView.closeButton.frame should equal(frame);
        });

        it(@"should position the button at the bottom left of the view for location: MPClosableViewCloseButtonLocationBottomLeft", ^{
            closableView.closeButtonLocation = MPClosableViewCloseButtonLocationBottomLeft;
            [closableView layoutSubviews];
            CGRect frame = CGRectMake(0.0f, viewFrame.size.height-closeHeight, closeWidth, closeHeight);
            closableView.closeButton.frame should equal(frame);
        });

        it(@"should position the button at the bottom right of the view for location: MPClosableViewCloseButtonLocationBottomRight", ^{
            closableView.closeButtonLocation = MPClosableViewCloseButtonLocationBottomRight;
            [closableView layoutSubviews];
            CGRect frame = CGRectMake(viewFrame.size.width-closeWidth, viewFrame.size.height-closeHeight, closeWidth, closeHeight);
            closableView.closeButton.frame should equal(frame);
        });

        it(@"should position the button at the top center of the view for location: MPClosableViewCloseButtonLocationTopCenter", ^{
            closableView.closeButtonLocation = MPClosableViewCloseButtonLocationTopCenter;
            [closableView layoutSubviews];
            CGRect frame = CGRectMake((viewFrame.size.width-closeWidth) / 2.0f, 0.0f, closeWidth, closeHeight);
            closableView.closeButton.frame should equal(frame);
        });

        it(@"should position the button at the bottom center of the view for location: MPClosableViewCloseButtonLocationBottomCenter", ^{
            closableView.closeButtonLocation = MPClosableViewCloseButtonLocationBottomCenter;
            [closableView layoutSubviews];
            CGRect frame = CGRectMake((viewFrame.size.width-closeWidth) / 2.0f, viewFrame.size.height-closeHeight, closeWidth, closeHeight);
            closableView.closeButton.frame should equal(frame);
        });

        it(@"should position the button at the center of the view for location: MPClosableViewCloseButtonLocationCenter", ^{
            closableView.closeButtonLocation = MPClosableViewCloseButtonLocationCenter;
            [closableView layoutSubviews];
            CGRect frame = CGRectMake((viewFrame.size.width-closeWidth) / 2.0f, (viewFrame.size.height-closeHeight) / 2.0f, closeWidth, closeHeight);
            closableView.closeButton.frame should equal(frame);
        });
    });
});

SPEC_END
