#import "MPInterstitialCustomEventAdapter.h"
#import "MPAdConfigurationFactory.h"
#import "FakeInterstitialCustomEvent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPInterstitialCustomEventAdapterMRCSpec)

describe(@"MPInterstitialCustomEventAdapterMRC", ^{
    context(@"when deallocated", ^{
        // There are scenarios where unregisterDelegate could be called synchronously in response to an "adDidFail" or "adDidDismiss" callback.  This can be problematic if unregisterDelegate synchronously deallocates the customEvent (which would deallocate the third party ad network object) as some third party SDKs do work immediately after sending their callbacks.

        it(@"should not deallocate the custom event immediately", ^{
            FakeInterstitialCustomEvent *event = [[FakeInterstitialCustomEvent alloc] init];
            fakeProvider.fakeInterstitialCustomEvent = event;

            id<CedarDouble, MPInterstitialAdapterDelegate> delegate = nice_fake_for(@protocol(MPInterstitialAdapterDelegate));
            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"FakeInterstitialCustomEvent"];

            @autoreleasepool {
                MPInterstitialCustomEventAdapter *adapter = [[MPInterstitialCustomEventAdapter alloc] initWithDelegate:delegate];
                [adapter _getAdWithConfiguration:configuration];

                event.delegate should equal(adapter);
                fakeProvider.fakeInterstitialCustomEvent = nil;
                [event release]; //the adapter has him now

                [adapter release];
            }

            //previously the event would be deallocated at this point.
            //not any more!
            event should be_instance_of([FakeInterstitialCustomEvent class]);

            event.delegate should be_nil;
            event.invalidated should equal(YES);
        });
    });

});

SPEC_END
