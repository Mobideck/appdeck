#import "NSURL+MPAdditions.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NSURL_MPAdditionsSpec)

describe(@"NSURL_MPAdditions", ^{
    describe(@"mp_queryAsDictionary", ^{
        it(@"should work", ^{
            NSURL *URL = [NSURL URLWithString:@"http://www.foo.com/magic/blah?q=123%2F4&bar&foo=125=abc=====&foo=5=abc=&&mwahaha="];
            URL.mp_queryAsDictionary should equal(@{@"q": @"123/4", @"foo":@"5", @"mwahaha":@""});
        });
    });

    describe(@"hasTelephoneScheme", ^{
        it(@"should detect telephone schemes case-insensitive", ^{
            NSURL *URL = [NSURL URLWithString:@"tel://5555555555"];
            [URL mp_hasTelephoneScheme] should equal(YES);

            URL = [NSURL URLWithString:@"tel:5555555555"];
            [URL mp_hasTelephoneScheme] should equal(YES);

            URL = [NSURL URLWithString:@"Tel://5555555555"];
            [URL mp_hasTelephoneScheme] should equal(YES);

            URL = [NSURL URLWithString:@"TeL://5555555555"];
            [URL mp_hasTelephoneScheme] should equal(YES);
        });

        it(@"should not detect telephone schemes when the URL doesn't have a telephone scheme", ^{
            NSURL *URL = [NSURL URLWithString:@"http://www.hargau.com"];
            [URL mp_hasTelephoneScheme] should equal(NO);

            URL = [NSURL URLWithString:@"https://tel.com"];
            [URL mp_hasTelephoneScheme] should equal(NO);

            URL = [NSURL URLWithString:@"telprompt://5555555555"];
            [URL mp_hasTelephoneScheme] should equal(NO);

            URL = [NSURL URLWithString:@"twitter://5555555555"];
            [URL mp_hasTelephoneScheme] should equal(NO);
        });
    });

    describe(@"hasTelephonePromptScheme", ^{
        it(@"should detect telephone prompt schemes case-insensitive", ^{
            NSURL *URL = [NSURL URLWithString:@"telprompt://5555555555"];
            [URL mp_hasTelephonePromptScheme] should equal(YES);

            URL = [NSURL URLWithString:@"telprompt:5555555555"];
            [URL mp_hasTelephonePromptScheme] should equal(YES);

            URL = [NSURL URLWithString:@"telPrompt://5555555555"];
            [URL mp_hasTelephonePromptScheme] should equal(YES);

            URL = [NSURL URLWithString:@"TelprompT://5555555555"];
            [URL mp_hasTelephonePromptScheme] should equal(YES);
        });

        it(@"should not detect telephone prompt schemes when the URL doesn't have a telephone prompt scheme", ^{
            NSURL *URL = [NSURL URLWithString:@"http://www.hargau.com"];
            [URL mp_hasTelephonePromptScheme] should equal(NO);

            URL = [NSURL URLWithString:@"https://tel.com"];
            [URL mp_hasTelephonePromptScheme] should equal(NO);

            URL = [NSURL URLWithString:@"tel://5555555555"];
            [URL mp_hasTelephonePromptScheme] should equal(NO);

            URL = [NSURL URLWithString:@"twitter://5555555555"];
            [URL mp_hasTelephonePromptScheme] should equal(NO);
        });
    });
});

SPEC_END
