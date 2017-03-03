#import "MPNativeAdSource.h"
#import "MPNativeAdSourceQueue.h"
#import "MPNativeAd+Internal.h"
#import "MPAdConfigurationFactory.h"
#import "NSJSONSerialization+MPAdditions.h"
#import "MPMoPubNativeAdAdapter.h"
#import "MPNativeAdSourceDelegate.h"
#import "CedarAsync.h"
#import "MPNativeAdRendererConfiguration.h"
#import "FakeNativeAdRenderingClass.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPNativeAdRendererConfiguration.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface MPNativeAdSource (Specs)

@property (nonatomic, retain) NSMutableDictionary *adQueueDictionary;

extern NSUInteger const kCacheSizeLimit;

@end

@interface MPNativeAdSourceQueue (Specs)

@property (nonatomic, retain) NSMutableArray *adQueue;

- (void)addNativeAd:(MPNativeAd *)nativeAd;

@end

@interface MPNativeAd (Specs)

@property (nonatomic, retain) NSDate *creationDate;

@end

SPEC_BEGIN(MPNativeAdSourceSpec)

describe(@"MPNativeAdSource", ^{
    __block MPNativeAdSource *adSource;
    __block MPAdConfiguration *configuration;
    __block id<MPNativeAdSourceDelegate, CedarDouble> delegate;
    __block MPStaticNativeAdRenderer *renderer;
    __block NSArray *nativeAdRendererConfigurations;

    context(@"when requesting real ads", ^{

        beforeEach(^{
            MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];

            settings.renderingViewClass = [FakeNativeAdRenderingClass class];
            settings.viewSizeHandler = ^(CGFloat maxWidth) {
                return CGSizeMake(70, 113);
            };

            renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];

            MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
            nativeAdRendererConfigurations = @[config];

            adSource = [MPNativeAdSource source];
            delegate = nice_fake_for(@protocol(MPNativeAdSourceDelegate));
            adSource.delegate = delegate;

            [adSource loadAdsWithAdUnitIdentifier:@"8ce943e5b65a4689b434d72736dbed02" rendererConfigurations:nativeAdRendererConfigurations andTargeting:nil];
        });

        it(@"should notify it's delegate when the first ad loads", ^{
            in_time(delegate should have_received(@selector(adSourceDidFinishRequest:)));
        });
    });

    context(@"when spoofing MPNativeAd contents of queue", ^{

        beforeEach(^{
            adSource = [MPNativeAdSource source];
            delegate = nice_fake_for(@protocol(MPNativeAdSourceDelegate));
            adSource.delegate = delegate;

            configuration = [MPAdConfigurationFactory defaultNativeAdConfiguration];

            MPNativeAdSourceQueue *newQueue = [[MPNativeAdSourceQueue alloc] initWithAdUnitIdentifier:@"identifier" rendererConfigurations:nativeAdRendererConfigurations andTargeting:nil];

            for (NSInteger x = 0; x < 3; x++) {
                NSMutableDictionary *properties = [NSJSONSerialization mp_JSONObjectWithData:configuration.adResponseData options:NSJSONReadingMutableContainers clearNullObjects:YES error:nil];
                [properties setObject:[NSString stringWithFormat:@"%ld", (long)x] forKey:@"title"];
                MPMoPubNativeAdAdapter *adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[properties mutableCopy]];
                MPNativeAd *fakeAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
                fakeAd.renderer = renderer;
                [newQueue addNativeAd:fakeAd];
            }

            [adSource.adQueueDictionary setObject:newQueue forKey:@"identifier"];
        });

        context(@"when three valid ads are in the queue for an ad unit", ^{

            it(@"should have three items in the queue", ^{
                [adSource.adQueueDictionary count] should equal(1);
                [[[adSource.adQueueDictionary objectForKey:@"identifier"] adQueue] count] should equal(3);
            });

            it(@"should dequeue ads in order", ^{
                for (NSInteger x = 0; x < 3; x++) {
                    MPNativeAd *nextAd = [adSource dequeueAdForAdUnitIdentifier:@"identifier"];
                    [[nextAd.properties objectForKey:@"title"] integerValue] should equal(x);
                }
            });

            it (@"should decrement queue size after dequeue", ^{
                MPNativeAd *nextAd = [adSource dequeueAdForAdUnitIdentifier:@"identifier"];
                (void)nextAd;  // Make Xcode think we're using the testAd so it'll compile.
                [[adSource.adQueueDictionary objectForKey:@"identifier"] count] should equal(2);
            });

            it (@"should call replenishCache: during dequeue", ^{
                MPNativeAdSourceQueue *queue = [adSource.adQueueDictionary objectForKey:@"identifier"];
                spy_on(queue);
                MPNativeAd *nextAd = [adSource dequeueAdForAdUnitIdentifier:@"identifier"];
                (void)nextAd;  // Make Xcode think we're using the testAd so it'll compile.
                queue should have_received(@selector(replenishCache));
            });

            it (@"should get rid of queue when close: is called", ^{
                [adSource deleteCacheForAdUnitIdentifier:@"identifier"];
                [adSource dequeueAdForAdUnitIdentifier:@"identifier"] should be_nil;
                [adSource.adQueueDictionary count] should equal(0);
            });
        });

        context(@"when an ad expires", ^{
            __block MPNativeAdSourceQueue *adQueue;

            beforeEach(^{
                adQueue = [adSource.adQueueDictionary objectForKey:@"identifier"];
                MPNativeAd *firstAd = [adQueue.adQueue firstObject];
                NSDate *oldDate = [NSDate dateWithTimeIntervalSince1970:0];
                NSLog(@"%@", oldDate);
                firstAd.creationDate = oldDate;
            });

            it (@"should return the second ad when dequeued", ^{
                MPNativeAd *nativeAd = [adSource dequeueAdForAdUnitIdentifier:@"identifier"];
                [[nativeAd.properties objectForKey:@"title"] integerValue] should equal(1);
            });

        });
    });

});

SPEC_END
