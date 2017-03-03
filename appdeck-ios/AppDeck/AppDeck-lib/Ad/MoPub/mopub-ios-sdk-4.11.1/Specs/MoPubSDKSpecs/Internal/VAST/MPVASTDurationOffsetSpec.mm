#import "MPVASTDurationOffset.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPVASTDurationOffsetSpec)

describe(@"MPVASTDurationOffset", ^{
    __block MPVASTDurationOffset *durationOffset;
    __block NSMutableDictionary *initializationDict;

    subjectAction(^{
        durationOffset = [[MPVASTDurationOffset alloc] initWithDictionary:initializationDict];
    });

    describe(@"initialization", ^{
        beforeEach(^{
            initializationDict = [NSMutableDictionary dictionary];
        });

        context(@"with an absolute 'offset'", ^{
            beforeEach(^{
                initializationDict[@"offset"] = @"01:20:30.400";
            });

            it(@"should return an object representing an absolute offset", ^{
                durationOffset.type should equal(MPVASTDurationOffsetTypeAbsolute);
                durationOffset.offset should equal(initializationDict[@"offset"]);
            });
        });

        context(@"with a percentage 'offset'", ^{
            beforeEach(^{
                initializationDict[@"offset"] = @"42%";
            });

            it(@"should return an object representing a percentage offset", ^{
                durationOffset.type should equal(MPVASTDurationOffsetTypePercentage);
                durationOffset.offset should equal(initializationDict[@"offset"]);
            });
        });

        context(@"with an invalid 'offset'", ^{
            beforeEach(^{
                initializationDict[@"offset"] = @"ab-cd5";
            });

            it(@"should return nil", ^{
                durationOffset should be_nil;
            });
        });

        context(@"with an absolute 'skipoffset'", ^{
            beforeEach(^{
                initializationDict[@"skipoffset"] = @"01:20:30.400";
            });

            it(@"should return an object representing an absolute offset", ^{
                durationOffset.type should equal(MPVASTDurationOffsetTypeAbsolute);
                durationOffset.offset should equal(initializationDict[@"skipoffset"]);
            });
        });

        context(@"with a percentage 'skipoffset'", ^{
            beforeEach(^{
                initializationDict[@"skipoffset"] = @"42%";
            });

            it(@"should return an object representing a percentage offset", ^{
                durationOffset.type should equal(MPVASTDurationOffsetTypePercentage);
                durationOffset.offset should equal(initializationDict[@"skipoffset"]);
            });
        });

        context(@"with an invalid 'skipoffset'", ^{
            beforeEach(^{
                initializationDict[@"skipoffset"] = @"ab-cd5";
            });

            it(@"should return nil", ^{
                durationOffset should be_nil;
            });
        });

    });

    describe(@"-timeIntervalForVideoWithDuration:", ^{
        context(@"with an absolute offset", ^{
            beforeEach(^{
                initializationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"00:00:12.5", @"offset", nil];
            });

            it(@"should return that value when given a positive duration", ^{
                [durationOffset timeIntervalForVideoWithDuration:10] should equal(12.5);
                [durationOffset timeIntervalForVideoWithDuration:100] should equal(12.5);
            });

            it(@"should return 0 when given a negative duration", ^{
                [durationOffset timeIntervalForVideoWithDuration:-100] should equal(0);
            });
        });

        context(@"with a percentage offset", ^{
            beforeEach(^{
                initializationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"50%", @"offset", nil];
            });

            it(@"should return the correct value relative to the video length", ^{
                [durationOffset timeIntervalForVideoWithDuration:10] should equal(5);
                [durationOffset timeIntervalForVideoWithDuration:100] should equal(50);
            });

            it(@"should return 0 when given a negative duration", ^{
                [durationOffset timeIntervalForVideoWithDuration:-100] should equal(0);
            });
        });
    });
});

SPEC_END
