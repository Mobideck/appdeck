#import "MPActivityViewControllerHelper+TweetShare.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPActivityViewControllerHelper_TweetShareSpec)

xdescribe(@"MPActivityViewControllerHelper_TweetShare", ^{
    __block MPActivityViewControllerHelper *activityViewControllerHelper;
    __block id<MPActivityViewControllerHelperDelegate> delegate;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPActivityViewControllerHelperDelegate));
        activityViewControllerHelper = [[MPActivityViewControllerHelper alloc] initWithDelegate:delegate];
        spy_on(activityViewControllerHelper);
    });

    describe(@"presentActivityViewControllerWithTweetShareURL", ^{
        it(@"with a valid share url calls underlying present method and returns YES", ^{
            NSURL *URL = [NSURL URLWithString:@"mopubshare://tweet?screen_name=SpaceX&tweet_id=596026229536460802"];
            [activityViewControllerHelper presentActivityViewControllerWithTweetShareURL:URL] should equal(YES);
            NSString *expectedMessage = @"Check out @SpaceX's Tweet: https://twitter.com/SpaceX/status/596026229536460802";
            activityViewControllerHelper should have_received(@selector(presentActivityViewControllerWithSubject:body:)).
                with(expectedMessage).and_with(expectedMessage);
        });

        it(@"with an invalid share url (missing screen name) does not call underlying present method and returns NO", ^{
            NSURL *URL = [NSURL URLWithString:@"mopubshare://tweet?tweet_id=596026229536460802"];
            [activityViewControllerHelper presentActivityViewControllerWithTweetShareURL:URL] should equal(NO);
            activityViewControllerHelper should_not have_received(@selector(presentActivityViewControllerWithSubject:body:));
        });

        it(@"with an invalid share url (missing tweet_id) does not call underlying present method and returns NO", ^{
            NSURL *URL = [NSURL URLWithString:@"mopubshare://tweet?screen_name=SpaceX"];
            [activityViewControllerHelper presentActivityViewControllerWithTweetShareURL:URL] should equal(NO);
            activityViewControllerHelper should_not have_received(@selector(presentActivityViewControllerWithSubject:body:));
        });
    });
});

SPEC_END
