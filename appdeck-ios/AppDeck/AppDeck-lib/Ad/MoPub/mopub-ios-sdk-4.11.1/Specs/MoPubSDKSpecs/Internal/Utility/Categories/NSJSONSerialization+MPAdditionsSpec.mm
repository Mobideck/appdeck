#import "NSJSONSerialization+MPAdditions.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NSJSONSerialization_MPAdditionsSpec)

describe(@"NSJSONSerialization_MPAdditions", ^{
    describe(@"mp_JSONObjectWithData:", ^{
        it(@"should recursively remove all key/values where the key points to a NULL value", ^{
            NSData *data = [@"{\"foo\":\"bar\", \"baz\":2, \"nah\":null, \"recurseDict\":{\"value\":\"a value!\", \"nullValue\":null}, \"testArray\":[\"item1\", {\"value\":\"a value!\", \"nullValue\":null}, null, null, null]}" dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *dictionary = nil;
            if (data) {
                dictionary = [NSJSONSerialization mp_JSONObjectWithData:data options:kNilOptions clearNullObjects:YES error:nil];
            }

            dictionary should equal(@{@"foo": @"bar", @"baz": @2, @"recurseDict": @{@"value": @"a value!"}, @"testArray": @[@"item1", @{@"value": @"a value!"}]});
        });
    });
});

SPEC_END
