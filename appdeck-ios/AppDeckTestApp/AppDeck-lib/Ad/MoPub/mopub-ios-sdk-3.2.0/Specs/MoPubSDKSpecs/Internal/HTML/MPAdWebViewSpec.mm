#import "MPAdWebView.h"
#import "MPAdConfigurationFactory.h"
#import "MPAdDestinationDisplayAgent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(MPAdWebViewSpec)

describe(@"MPAdWebView", ^{
    __block MPAdWebView *view;

    beforeEach(^{
        view = [[MPAdWebView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    });

    describe(@"on init, setting up the webview", ^{
        it(@"should allow inline media playback without user action", ^{
            view.allowsInlineMediaPlayback should equal(YES);
            view.mediaPlaybackRequiresUserAction should equal(NO);
        });
    });
});

SPEC_END
