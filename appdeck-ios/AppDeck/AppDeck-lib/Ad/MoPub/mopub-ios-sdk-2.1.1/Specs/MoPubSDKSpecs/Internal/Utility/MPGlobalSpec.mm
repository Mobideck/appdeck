#import "MPGlobal.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPGlobalSpec)

describe(@"MPGlobal", ^{
    it(@"should be tested someday", PENDING);

    describe(@"MPTelephoneConfirmationController", ^{
        context(@"initialization", ^{
            it(@"should return nil for non telephone URLs", ^{
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"http://www.zombo.com"] clickHandler:nil] should be_nil;
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"twitter://idontknow"] clickHandler:nil] should be_nil;
            });

            it(@"should return nil for tel: and telPrompt: URLs with no number", ^{
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"tel:"] clickHandler:nil] autorelease] should be_nil;
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"telprompt:"] clickHandler:nil] autorelease] should be_nil;
            });

            it(@"should initialize for tel scheme URLs", ^{
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"tel://3439899999"] clickHandler:nil] autorelease] should_not be_nil;
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"tel:3439899999"] clickHandler:nil] autorelease] should_not be_nil;
            });

            it(@"should initialize for telprompt scheme URLs", ^{
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"telprompt://3439899999"] clickHandler:nil] autorelease] should_not be_nil;
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"telprompt:3439899999"] clickHandler:nil] autorelease] should_not be_nil;
            });
        });
    });
});

SPEC_END
