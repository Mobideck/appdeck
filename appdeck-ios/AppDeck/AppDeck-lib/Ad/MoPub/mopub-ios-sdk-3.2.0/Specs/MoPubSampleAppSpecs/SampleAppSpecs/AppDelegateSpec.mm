#import "AppDelegate.h"
#import "MPAdTableViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AppDelegateSpec)

describe(@"AppDelegate", ^{
    __block AppDelegate *delegate;

    beforeEach(^{
        delegate = [[[AppDelegate alloc] init] autorelease];
        [delegate application:nil didFinishLaunchingWithOptions:nil];
    });

    it(@"should have a window with a root view controller", ^{
        delegate.window.rootViewController should be_instance_of([UINavigationController class]);
        [(UINavigationController *)delegate.window.rootViewController visibleViewController] should be_instance_of([MPAdTableViewController class]);
    });
});

SPEC_END
