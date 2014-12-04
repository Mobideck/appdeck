#import "MRPictureManager.h"
#import "FakeMRImageDownloader.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MRPictureManagerSpec)

describe(@"MRPictureManager", ^{
    __block MRPictureManager *manager;
    __block id<MRPictureManagerDelegate, CedarDouble> delegate;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MRPictureManagerDelegate));
        manager = [[[MRPictureManager alloc] initWithDelegate:delegate] autorelease];
    });

    describe(@"-storePicture:", ^{
        __block FakeMRImageDownloader *imageDownloader;

        context(@"if the provided URL is nil", ^{
            beforeEach(^{
                [manager storePicture:nil];
            });

            it(@"should inform the delegate that an error occurred", ^{
                delegate should have_received(@selector(pictureManager:didFailToStorePictureWithErrorMessage:)).with(manager).and_with(Arguments::anything);
            });
        });

        context(@"with a valid URI parameter", ^{
            __block UIAlertView *alertView;

            beforeEach(^{
                [manager storePicture:[NSURL URLWithString:@"http://imageuri"]];
                alertView = [UIAlertView currentAlertView];
            });

            it(@"shows an alert view that allows the user to decide if a picture can be saved", ^{
                alertView.numberOfButtons should equal(2);
                alertView should_not be_nil;
            });

            context(@"when the user chooses not to save the picture", ^{
                beforeEach(^{
                    [alertView dismissWithCancelButton];
                });

                it(@"should inform its delegate that an error occurred", ^{
                    delegate should have_received(@selector(pictureManager:didFailToStorePictureWithErrorMessage:)).with(manager).and_with(Arguments::anything);
                });
            });

            context(@"when the user chooses to save the picture but the image fails to download", ^{
                beforeEach(^{
                    imageDownloader = [[[FakeMRImageDownloader alloc] init] autorelease];
                    imageDownloader.willSucceed = NO;
                    fakeProvider.fakeImageDownloader = imageDownloader;

                    [manager storePicture:[NSURL URLWithString:@"http://imageuri"]];
                    [alertView dismissWithOkButton];
                });

                it(@"should inform its delegate that an error occurred", ^{
                    delegate should have_received(@selector(pictureManager:didFailToStorePictureWithErrorMessage:)).with(manager).and_with(Arguments::anything);
                });
            });
        });
    });
});

SPEC_END
