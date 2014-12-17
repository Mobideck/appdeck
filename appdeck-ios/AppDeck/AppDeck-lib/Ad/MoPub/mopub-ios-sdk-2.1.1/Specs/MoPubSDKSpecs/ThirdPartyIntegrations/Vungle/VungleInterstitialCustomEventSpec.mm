#import "VungleInterstitialCustomEvent.h"
#import "VGVunglePub+Specs.h"

#import <CoreLocation/CoreLocation.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

static void
RestartVungle(VungleInterstitialCustomEvent *model, NSDictionary *customInfo)
{
    [VGVunglePub stop];
    [model requestInterstitialWithCustomEventInfo:customInfo];
}

SPEC_BEGIN(VungleInterstitialCustomEventSpec)

describe(@"VungleInterstitialCustomEvent", ^{
    __block VungleInterstitialCustomEvent *model;
    __block id<CedarDouble, MPInterstitialCustomEventDelegate> delegate;

    beforeEach(^{
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            [VGVunglePub mp_swizzleStartMethod];
        });
    
        model = [[[VungleInterstitialCustomEvent alloc] init] autorelease];
        delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
        model.delegate = delegate;
    });
    
    context(@"when requesting a Vungle video ad", ^{
        beforeEach(^{
            [model requestInterstitialWithCustomEventInfo:nil];
        });
        
        it(@"should set itself as Vungle's delegate", ^{
            [VGVunglePub delegate] should equal(model);
        });
        
        it(@"should set the default app id as Vungle's app id", ^{
            [VGVunglePub mp_getAppId] should equal(@"YOUR_VUNGLE_APP_ID");
        });

        context(@"when the delegate does not specify a location", ^{
           it(@"should not enable Vungle location", ^{
               [VGVunglePub mp_getUserData].locationEnabled should equal(NO);
           });
        });
        
        context(@"when Vungle sends us an error status update", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [VGVunglePub mp_sendErrorStatusUpdate];
            });
            
            it(@"should notify the delegate", ^{
                delegate.sent_messages.count should equal(1);
                delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:));
            });
        });
        
        context(@"when Vungle sends us multiple status updates", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [VGVunglePub mp_sendErrorStatusUpdate];
                [VGVunglePub mp_sendErrorStatusUpdate];
            });
            
            it(@"should notify the delegate only once", ^{
                delegate.sent_messages.count should equal(1);
                delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:));
            });
        });
    });
    
    context(@"when requesting a Vungle video ad with custom app id", ^{
        beforeEach(^{
            RestartVungle(model, [NSDictionary dictionaryWithObject:@"CUSTOM_APP_ID" forKey:@"appId"]);
        });
        
        it(@"should set the custom app id as Vungle's app id", ^{
            [VGVunglePub mp_getAppId] should equal(@"CUSTOM_APP_ID");
        });
    });
    
    context(@"when the delegate does specify a location", ^{
        beforeEach(^{
            CLLocation *location = [[[CLLocation alloc] initWithLatitude:1337 longitude:1337] autorelease];
            delegate stub_method("location").and_return(location);
            
            RestartVungle(model, nil);
        });
        
        it(@"should enable Vungle location", ^{
            [VGVunglePub mp_getUserData].locationEnabled should equal(YES);
        });
    });
    
    context(@"when there are multiple requests to load a Vungle video ad", ^{
        __block VungleInterstitialCustomEvent *secondModel;
        __block id<CedarDouble, MPInterstitialCustomEventDelegate> secondDelegate;
        
        beforeEach(^{
            secondModel = [[[VungleInterstitialCustomEvent alloc] init] autorelease];
            secondDelegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
            secondModel.delegate = secondDelegate;
            
            [model requestInterstitialWithCustomEventInfo:nil];
            [secondModel requestInterstitialWithCustomEventInfo:nil];
        });
        
        it(@"secondModel should be the Vungle delegate", ^{
            [VGVunglePub delegate] should equal(secondModel);
            
            [VGVunglePub mp_sendErrorStatusUpdate];
            secondDelegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:));
            delegate should_not have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:));
        });
        
        context(@"when the current Vungle delegate is invalidated", ^{
            beforeEach(^{
                [secondModel performSelector:@selector(invalidate) withObject:nil];
            });
            
            it(@"should nil out the Vungle delegate", ^{
                [VGVunglePub delegate] should be_nil;
            });
            
            context(@"when another custom event requests a Vungle ad", ^{
                beforeEach(^{
                    [model requestInterstitialWithCustomEventInfo:nil];
                });
                
                it(@"should be the Vungle delegate", ^{
                    [VGVunglePub delegate] should equal(model);
                });
            });
        });
    });
});

SPEC_END
