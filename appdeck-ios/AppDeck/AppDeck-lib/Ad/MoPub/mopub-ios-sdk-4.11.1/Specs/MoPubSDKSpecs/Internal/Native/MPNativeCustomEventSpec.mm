#import "MPNativeCustomEvent.h"
#import "NSOperationQueue+MPSpecs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPNativeCustomEventSpec)

describe(@"MPNativeCustomEvent", ^{
    __block MPNativeCustomEvent *customEvent;

    beforeEach(^{
        customEvent = [[MPNativeCustomEvent alloc] init];
        [NSOperationQueue mp_resetAddOperationWithBlockCount];
    });

    context(@"when downloading images", ^{

        it(@"should not crash on nil completion block", ^{
            ^{
                [customEvent precacheImagesWithURLs:@[] completionBlock:nil];
            } should_not raise_exception;
        });

        it(@"should not crash on nil array", ^{
            ^{
                [customEvent precacheImagesWithURLs:nil completionBlock:nil];
            } should_not raise_exception;
        });

        it(@"should initiate N+1 operations for N images", ^{
            // This is really just to make sure it uses the image download queue.  All the other tests are covered in the image download queue.
            NSURL *url = [NSURL URLWithString:@"https://www.google.com/images/srpr/logo11w.png"];
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(0);
            [customEvent precacheImagesWithURLs:@[url,url] completionBlock:^(NSArray *errors) {}];
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(3);
        });
    });
});

SPEC_END
