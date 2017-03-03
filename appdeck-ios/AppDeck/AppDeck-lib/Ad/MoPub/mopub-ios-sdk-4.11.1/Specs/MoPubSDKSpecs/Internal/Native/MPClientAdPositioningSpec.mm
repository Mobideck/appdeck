#import "MPClientAdPositioning.h"
#import <UIKit/UIKit.h>
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(MPClientAdPositioningSpec)

describe(@"MPClientAdPositioning", ^{
    __block MPClientAdPositioning *positioning;

    beforeEach(^{
        positioning = [MPClientAdPositioning positioning];

        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *path2 = [NSIndexPath indexPathForRow:5 inSection:0];
        [positioning addFixedIndexPath:path];
        [positioning addFixedIndexPath:path2];
    });

    context(@"when the positiong object doesn't have repeat interval enabled", ^{
        it (@"should have a repeating interval of 0", ^{
            positioning.repeatingInterval should equal(0);
        });
    });

    context(@"when the positioning has items added and repeat interval enabled", ^{

        beforeEach(^{
            [positioning enableRepeatingPositionsWithInterval:10];

        });

        it (@"should have two index paths in it's fixed set", ^{
            [positioning.fixedPositions count] should equal(2);
        });

        it (@"should have a repeating interval of 10", ^{
            positioning.repeatingInterval should equal(10);
        });
    });

    context(@"when additions and changes are made to positioning", ^{
        it (@"should do nothing when trying to set a repeating interval of 1", ^{
            NSUInteger repeatingInterval = positioning.repeatingInterval;
            [positioning enableRepeatingPositionsWithInterval:1];
            positioning.repeatingInterval should equal(repeatingInterval);
        });

        it (@"should not add duplicate index paths to fixedPositions", ^{
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
            [positioning addFixedIndexPath:path];
            [positioning.fixedPositions count] should equal(2);
        });
    });

    context(@"when copying the original positioning object", ^{
        __block MPClientAdPositioning *newPositioning;

        beforeEach(^{
            [positioning enableRepeatingPositionsWithInterval:5];
            newPositioning = [positioning copy];
        });

        it(@"should have the same repeating interval", ^{
            newPositioning.repeatingInterval should equal(5);
        });

        it(@"should have the same fixed indexes", ^{
            [newPositioning.fixedPositions count] should equal([positioning.fixedPositions count]);
            [newPositioning.fixedPositions containsObject:[NSIndexPath indexPathForRow:0 inSection:0]] should be_truthy;
            [newPositioning.fixedPositions containsObject:[NSIndexPath indexPathForRow:5 inSection:0]] should be_truthy;
        });

    });
});

SPEC_END
