#import "MPNativePositionResponseDeserializer.h"
#import "MPClientAdPositioning.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

static NSData *MPJSONToData(NSDictionary *JSON) {
    return [NSJSONSerialization dataWithJSONObject:JSON options:0 error:nil];
}

static NSString * const aDeserializerThatFails = @"a deserializer that fails";

SPEC_BEGIN(MPNativePositionResponseDeserializerSpec)

describe(@"MPNativePositionResponseDeserializer", ^{
    __block MPNativePositionResponseDeserializer *deserializer;

    beforeEach(^{
        deserializer = [MPNativePositionResponseDeserializer deserializer];
    });

    describe(@"-clientPositioningForData:error:", ^{
        __block NSData *data;
        __block NSError *error;
        __block MPClientAdPositioning *positioning;

        sharedExamplesFor(aDeserializerThatFails, ^(NSDictionary *sharedContext) {
            it(@"should return an empty positioning object and an error", ^{
                positioning.fixedPositions should be_empty;
                error should_not be_nil;
            });
        });

        beforeEach(^{
            error = nil;
            data = nil;
        });

        subjectAction(^{
            positioning = [deserializer clientPositioningForData:data error:&error];
        });

        context(@"with nil data", ^{
            itShouldBehaveLike(aDeserializerThatFails);
        });

        context(@"with 0-length data", ^{
            beforeEach(^{
                data = [NSData data];
            });

            itShouldBehaveLike(aDeserializerThatFails);
        });

        context(@"with data that does not contain valid JSON", ^{
            beforeEach(^{
                data = [@"{\"not-json\"}" dataUsingEncoding:NSUTF8StringEncoding];
            });

            itShouldBehaveLike(aDeserializerThatFails);
        });

        context(@"with data that contains JSON", ^{
            context(@"representing valid positioning", ^{
                beforeEach(^{
                    data = MPJSONToData(@{@"fixed": @[
                                                  @{@"position": @1},
                                                  @{@"section": @1, @"position": @10}],
                                          @"repeating": @{@"interval": @12}});
                });

                it(@"should return a non-empty positioning object", ^{
                    positioning.fixedPositions should contain([NSIndexPath indexPathForItem:1 inSection:0]);
                    positioning.fixedPositions should contain([NSIndexPath indexPathForItem:10 inSection:1]);
                    [positioning.fixedPositions count] should equal(2);
                    positioning.repeatingInterval should equal(12);
                    error should be_nil;
                });

                context(@"with position / interval values that are represented as strings", ^{
                    beforeEach(^{
                        data = MPJSONToData(@{@"fixed": @[
                                                      @{@"position": @"1"},
                                                      @{@"section": @"1", @"position": @"10"}],
                                              @"repeating": @{@"interval": @"12"}});
                    });

                    it(@"should return a non-empty positioning object", ^{
                        positioning.fixedPositions should contain([NSIndexPath indexPathForItem:1 inSection:0]);
                        positioning.fixedPositions should contain([NSIndexPath indexPathForItem:10 inSection:1]);
                        [positioning.fixedPositions count] should equal(2);
                        positioning.repeatingInterval should equal(12);
                        error should be_nil;
                    });
                });

                context(@"with multiple fixed positions that are the same", ^{
                    beforeEach(^{
                        data = MPJSONToData(@{@"fixed": @[
                                                      @{@"section": @0, @"position": @1},
                                                      @{@"section": @0, @"position": @1}],
                                              @"repeating": @{@"interval": @12}});
                    });

                    it(@"should return a positioning object that does not have duplicate positions", ^{
                        [positioning.fixedPositions count] should equal(1);
                        positioning.fixedPositions should contain([NSIndexPath indexPathForItem:1 inSection:0]);
                        positioning.repeatingInterval should equal(12);
                        error should be_nil;
                    });
                });

                context(@"without fixed positions but with a repeating interval", ^{
                    beforeEach(^{
                        data = MPJSONToData(@{@"repeating": @{@"interval": @12}});
                    });

                    it(@"should return a positioning object with a repeating interval", ^{
                        positioning.fixedPositions should be_empty;
                        positioning.repeatingInterval should equal(12);
                        error should be_nil;
                    });
                });

                context(@"without a repeating interval but with fixed positions", ^{
                    beforeEach(^{
                        data = MPJSONToData(@{@"fixed": @[
                                                      @{@"section": @0, @"position": @1},
                                                      @{@"section": @3, @"position": @5}]});
                    });

                    it(@"should return a positioning object with 0 repeating interval", ^{
                        positioning.fixedPositions should contain([NSIndexPath indexPathForItem:1 inSection:0]);
                        positioning.fixedPositions should contain([NSIndexPath indexPathForItem:5 inSection:3]);
                        [positioning.fixedPositions count] should equal(2);
                        positioning.repeatingInterval should equal(0);
                        error should be_nil;
                    });
                });
            });

            context(@"with invalid values", ^{
                context(@"with invalid positions", ^{
                    it(@"should return an empty positioning object and an error", ^{
                        // @"string" is not a valid position.
                        NSDictionary *JSON = @{@"fixed": @[@{@"section": @0, @"position": @"string"}]};
                        positioning = [deserializer clientPositioningForData:MPJSONToData(JSON) error:&error];
                        positioning.fixedPositions should be_empty;
                        error should_not be_nil;

                        // Section is not allowed to be negative.
                        JSON = @{@"fixed": @[@{@"section": @"-1", @"position": @1}]};
                        positioning = [deserializer clientPositioningForData:MPJSONToData(JSON) error:&error];
                        positioning.fixedPositions should be_empty;
                        error should_not be_nil;

                        // Position is not allowed to be negative.
                        JSON = @{@"fixed": @[@{@"section": @(1), @"position": @(-1)}]};
                        positioning = [deserializer clientPositioningForData:MPJSONToData(JSON) error:&error];
                        positioning.fixedPositions should be_empty;
                        error should_not be_nil;

                        // Position is required, not optional.
                        JSON = @{@"fixed": @[@{@"section": @(1)}]};
                        positioning = [deserializer clientPositioningForData:MPJSONToData(JSON) error:&error];
                        positioning.fixedPositions should be_empty;
                        error should_not be_nil;

                        // A valid position followed by an invalid one.
                        JSON = @{@"fixed": @[@{@"section": @(1), @"position": @(2)},
                                             @{@"section": @(-1)}]};
                        positioning = [deserializer clientPositioningForData:MPJSONToData(JSON) error:&error];
                        positioning.fixedPositions should be_empty;
                        error should_not be_nil;
                    });
                });

                context(@"with a negative repeating interval", ^{
                    beforeEach(^{
                        data = MPJSONToData(@{@"repeating": @{@"interval": @(-1)}});
                    });

                    itShouldBehaveLike(aDeserializerThatFails);
                });

                context(@"with a repeating interval that is too small", ^{
                    beforeEach(^{
                        data = MPJSONToData(@{@"repeating": @{@"interval": @0}});
                    });

                    itShouldBehaveLike(aDeserializerThatFails);
                });

                context(@"with a repeating interval that is too large", ^{
                    beforeEach(^{
                        data = MPJSONToData(@{@"repeating": @{@"interval": @(1 << 20)}});
                    });

                    itShouldBehaveLike(aDeserializerThatFails);
                });

                context(@"with an invalid repeating object", ^{
                    beforeEach(^{
                        data = MPJSONToData(@{@"repeating": @"not-an-object"});
                    });

                    itShouldBehaveLike(aDeserializerThatFails);
                });
            });

            context(@"missing expected values", ^{
                context(@"with empty fixed positions and no repeating interval", ^{
                    beforeEach(^{
                        data = MPJSONToData(@{@"fixed": @[]});
                    });

                    itShouldBehaveLike(aDeserializerThatFails);
                });

                context(@"with an empty repeating interval object", ^{
                    beforeEach(^{
                        data = MPJSONToData(@{@"repeating": @{}});
                    });

                    itShouldBehaveLike(aDeserializerThatFails);
                });

                context(@"with empty fixed positions and an empty repeating interval object", ^{
                    beforeEach(^{
                        data = MPJSONToData(@{@"fixed": @[], @"repeating": @{}});
                    });

                    itShouldBehaveLike(aDeserializerThatFails);
                });
            });
        });
    });
});

SPEC_END
