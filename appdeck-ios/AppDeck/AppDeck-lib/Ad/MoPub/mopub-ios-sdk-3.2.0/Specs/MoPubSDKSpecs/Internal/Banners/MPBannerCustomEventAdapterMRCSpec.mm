#import "FakeBannerCustomEvent.h"
#import "MPBannerCustomEventAdapter.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPBannerCustomEventAdapterMRCSpec)

describe(@"MPBannerCustomEventAdapterMRCSpec", ^{
    context(@"when told to unregisterDelegate", ^{
        // There are scenarios where unregisterDelegate could be called synchronously in response to an "adDidFail" or "adDidDismiss" callback (basically, there is another banner ad waiting in the wings, it can be swapped in synchronously).  This can be problematic if unregisterDelegate synchronously deallocates the customEvent (which would deallocate the third party ad network object) as some third party SDKs do work immediately after sending their callbacks.

        it(@"should not deallocate the custom event immediately", ^{
            FakeBannerCustomEvent *event = [[FakeBannerCustomEvent alloc] initWithFrame:CGRectZero];
            fakeProvider.fakeBannerCustomEvent = event;

            id<CedarDouble, MPBannerAdapterDelegate> delegate = nice_fake_for(@protocol(MPBannerAdapterDelegate));
            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];

            @autoreleasepool {
                MPBannerCustomEventAdapter *adapter = [[MPBannerCustomEventAdapter alloc] initWithDelegate:delegate];
                [adapter _getAdWithConfiguration:configuration containerSize:CGSizeZero];
                event.delegate should equal(adapter);

                fakeProvider.fakeBannerCustomEvent = nil;
                [event release]; //the adapter has him now

                [adapter release];
            }

            //previously the event would be deallocated at this point.
            //not any more!
            event should be_instance_of([FakeBannerCustomEvent class]);

            event.delegate should be_nil;
            event.invalidated should equal(YES);
            event.view should_not be_nil;
        });
    });
});

SPEC_END
