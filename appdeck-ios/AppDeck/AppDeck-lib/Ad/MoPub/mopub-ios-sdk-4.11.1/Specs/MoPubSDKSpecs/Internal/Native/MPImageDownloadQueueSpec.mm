#import "MPImageDownloadQueue.h"
#import "NSOperationQueue+MPSpecs.h"
#import "MPNativeCache+Specs.h"
#import "CedarAsync.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(MPImageDownloadQueueSpec)

describe(@"MPImageDownloadQueue", ^{
    __block MPImageDownloadQueue *downloadQueue;

    beforeEach(^{
        downloadQueue = [[MPImageDownloadQueue alloc] init];

        [NSOperationQueue mp_resetCancelAllOperationsCalled];
        [NSOperationQueue mp_resetAddOperationWithBlockCount];
    });

    afterEach(^{
         downloadQueue = nil;
    });

//    context(@"when adding any amount of image URLs", ^{
//        it(@"should call the completion block", ^{
//            __block BOOL completionCalled = NO;
//            // Pass in an empty array to make it faster and not depend on the network.
//            [downloadQueue addDownloadImageURLs:@[] completionBlock:^(NSArray *errors) {
//                completionCalled = YES;
//            }];
//
//            in_time(completionCalled) should be_truthy();
//        });
//    });

    context(@"when adding valid image urls to download", ^{
        __block NSArray *urls;
        beforeEach(^{
            // images from our sample native ad
            NSURL *image = [NSURL URLWithString:kMPSpecsTestImageURL];
            urls = @[image, image];

            [NSOperationQueue mp_resetCancelAllOperationsCalled];
            [NSOperationQueue mp_resetAddOperationWithBlockCount];
        });

        it(@"should add N+1 operations to the operation queue for N URLs", ^{
            // It should add 1 more operation to notify the main thread that it's done.
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(0);
            [downloadQueue addDownloadImageURLs:urls completionBlock:^(NSArray *errors) {}];
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(urls.count + 1);
        });

        it(@"should cancel the operations on the operation queue when cancel is called on the download queue", ^{
            [NSOperationQueue mp_cancelAllOperationsCalled] should be_falsy();
            [downloadQueue addDownloadImageURLs:urls completionBlock:^(NSArray *errors) {}];
            [downloadQueue cancelAllDownloads];
            [NSOperationQueue mp_cancelAllOperationsCalled] should be_truthy();
        });
    });


    NSURL *testURL = [NSURL URLWithString:@"https://d30x8mtr3hjnzo.cloudfront.net/creatives/b4a0d9b16485480ca2fec85845275276"];

    // We would have retrieved this data to run tests against, but we're going to leave this commented out for now to keep tests quick.
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSData *testData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:testURL]
//                                             returningResponse:&response
//                                                         error:&error];
//
//    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];

    context(@"when requesting image that is already in the cache", ^{
        __block NSData *cachedData;

        beforeEach(^{
            // Store some bogus data for the testURL.
            cachedData = [[NSData alloc] initWithBytes:"whatever" length:8];
            [[MPNativeCache sharedCache] storeData:cachedData forKey:testURL.absoluteString];
        });

        context(@"when not specifying to read from cache (not passing an argument to/not to read from the cache)", ^{
            it(@"should read the data from the cache", ^{
                __block NSData *retrievedData = nil;
                [downloadQueue addDownloadImageURLs:@[testURL] completionBlock:^(NSArray *errors) {
                    retrievedData = [[MPNativeCache sharedCache] retrieveDataForKey:testURL.absoluteString];
                }];

                in_time(retrievedData) should equal(cachedData);
            });
        });

        context(@"when specifying to read from cache", ^{
            it(@"should read the data from the cache", ^{
                __block NSData *retrievedData = nil;
                [downloadQueue addDownloadImageURLs:@[testURL] completionBlock:^(NSArray *errors) {
                    retrievedData = [[MPNativeCache sharedCache] retrieveDataForKey:testURL.absoluteString];
                } useCachedImage:YES];

                in_time(retrievedData) should equal(cachedData);
            });
        });

        // This test depends on the network.  It's nice to have, but we don't want it slowing down the tests.
//        context(@"when specifying to not read from cache", ^{
//            it(@"should not read the data from the cache", ^{
//                __block NSData *retrievedData = nil;
//                [downloadQueue addDownloadImageURLs:@[testURL] completionBlock:^(NSArray *errors) {
//                    retrievedData = [[MPNativeCache sharedCache] retrieveDataForKey:testURL.absoluteString];
//                } useCachedImage:NO];
//
//                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
//
//                retrievedData should_not equal(cachedData);
//                retrievedData should equal(testData);
//
//                [[MPNativeCache sharedCache] removeAllDataFromCache];
//            });
//        });
    });

    // Commenting these out because they'll take too long to run and could potentially give a false error due to network conditions.  But they're also nice to have.
//    context(@"when requesting image that is not already in the cache", ^{
//
//        beforeEach(^{
//            [[MPNativeCache sharedCache] removeAllDataFromCache];
//            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
//        });
//
//        context(@"when not specifying to read from cache (not passing an argument to/not to read from the cache)", ^{
//            it(@"should retrieve correct data from URL", ^{
//                __block NSData *retrievedData = nil;
//                [downloadQueue addDownloadImageURLs:@[testURL] completionBlock:^(NSArray *errors) {
//                    retrievedData = [[MPNativeCache sharedCache] retrieveDataForKey:testURL.absoluteString];
//                }];
//
//                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
//
//                retrievedData should equal(testData);
//            });
//        });
//
//        context(@"when specifying to read from cache", ^{
//            it(@"should retrieve correct data from URL", ^{
//                __block NSData *retrievedData = nil;
//                [downloadQueue addDownloadImageURLs:@[testURL] completionBlock:^(NSArray *errors) {
//                    retrievedData = [[MPNativeCache sharedCache] retrieveDataForKey:testURL.absoluteString];
//                } useCachedImage:YES];
//
//                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
//
//                retrievedData should equal(testData);
//            });
//        });
//
//        context(@"when specifying to not read from cache", ^{
//            it(@"should retrieve correct data from URL", ^{
//                __block NSData *retrievedData = nil;
//                [downloadQueue addDownloadImageURLs:@[testURL] completionBlock:^(NSArray *errors) {
//                    retrievedData = [[MPNativeCache sharedCache] retrieveDataForKey:testURL.absoluteString];
//                } useCachedImage:NO];
//
//                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
//
//                retrievedData should equal(testData);
//
//            });
//        });
//    });
});

SPEC_END
