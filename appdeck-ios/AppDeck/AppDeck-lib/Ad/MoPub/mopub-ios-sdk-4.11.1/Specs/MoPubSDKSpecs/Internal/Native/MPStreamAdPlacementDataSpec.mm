#import "MPStreamAdPlacementData+Specs.h"
#import "MPNativeAdData.h"
#import "MPClientAdPositioning.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPStreamAdPlacementDataSpec)

describe(@"MPStreamAdPlacementData", ^{
    __block MPStreamAdPlacementData *dataWithFixedAndRepeating;
    __block MPStreamAdPlacementData *dataWithFixedOnly;
    __block MPStreamAdPlacementData *dataWithRepeatingOnly;
    __block MPStreamAdPlacementData *dataWithEmptyPositioning;

    beforeEach(^{
        /*

         0  Item A
         1  Item B
         2  Item C
         3  Item D
         4  Item E
         5  Item F
         6  Item G

         0  Item A
         1  Ad
         2  Item B
         3  Ad
         4  Item C
         5  Item D
         6  Ad
         7  Item E
         8  Item F
         9  Ad
         10 Item G

         */

        MPClientAdPositioning *fixedAndRepeatingPositioning = [MPClientAdPositioning positioning];
        [fixedAndRepeatingPositioning addFixedIndexPath:_IP(1, 0)];
        [fixedAndRepeatingPositioning addFixedIndexPath:_IP(3, 0)];
        [fixedAndRepeatingPositioning enableRepeatingPositionsWithInterval:3];

        MPClientAdPositioning *fixedOnlyPositioning = [MPClientAdPositioning positioning];
        [fixedOnlyPositioning addFixedIndexPath:_IP(0, 0)];
        [fixedOnlyPositioning addFixedIndexPath:_IP(3, 0)];
        [fixedOnlyPositioning addFixedIndexPath:_IP(0, 1)];
        [fixedOnlyPositioning addFixedIndexPath:_IP(3, 1)];

        MPClientAdPositioning *repeatingOnlyPositioning = [MPClientAdPositioning positioning];
        [repeatingOnlyPositioning enableRepeatingPositionsWithInterval:2];

        MPClientAdPositioning *emptyPositioning = [MPClientAdPositioning positioning];

        dataWithFixedAndRepeating = [[MPStreamAdPlacementData alloc] initWithPositioning:fixedAndRepeatingPositioning];
        dataWithFixedOnly = [[MPStreamAdPlacementData alloc] initWithPositioning:fixedOnlyPositioning];
        dataWithRepeatingOnly = [[MPStreamAdPlacementData alloc] initWithPositioning:repeatingOnlyPositioning];
        dataWithEmptyPositioning = [[MPStreamAdPlacementData alloc] initWithPositioning:emptyPositioning];
    });

    context(@"upon initialization", ^{
        it(@"should have an adjusted item count equal to the original item count", ^{
            NSArray *counts = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
            for (NSUInteger i = 0; i < [counts count]; i++) {
                [dataWithFixedAndRepeating adjustedNumberOfItems:i inSection:0] should equal([counts[i] integerValue]);
                [dataWithFixedOnly adjustedNumberOfItems:i inSection:0] should equal([counts[i] integerValue]);
                [dataWithFixedOnly adjustedNumberOfItems:i inSection:1] should equal([counts[i] integerValue]);
                [dataWithRepeatingOnly adjustedNumberOfItems:i inSection:0] should equal([counts[i] integerValue]);
                [dataWithEmptyPositioning adjustedNumberOfItems:i inSection:0] should equal([counts[i] integerValue]);
            }
        });

        it(@"should return adjusted index paths that are the same as the original index paths", ^{
            NSArray *counts = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
            for (NSUInteger i = 0; i < [counts count]; i++) {
                [dataWithFixedAndRepeating adjustedIndexPathForOriginalIndexPath:_IP(i, 0)] should equal(_IP([counts[i] integerValue], 0));
                [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(i, 0)] should equal(_IP([counts[i] integerValue], 0));
                [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(i, 1)] should equal(_IP([counts[i] integerValue], 1));
                [dataWithRepeatingOnly adjustedIndexPathForOriginalIndexPath:_IP(i, 0)] should equal(_IP([counts[i] integerValue], 0));
                [dataWithEmptyPositioning adjustedIndexPathForOriginalIndexPath:_IP(i, 0)] should equal(_IP([counts[i] integerValue], 0));
            }
        });

        it(@"should return correct insertion positions according to its positioning object", ^{
            /*

             0  Item A
                        <-- Ad
             1  Item B
                        <-- Ad
             2  Item C
             3  Item D
                        <-- Ad
             4  Item E
             5  Item F
                        <-- Ad
             6  Item G
             7  Item H
                        <-- Ad
             8  Item I
             9  Item J
                        <-- Ad
             10 Item K

             */

            NSArray *expectedInsertionFixedAndRepeating = @[@1, @1, @2, @4, @4, @6, @6, @8, @8, @10, @10];
            for (NSUInteger i = 0; i < [expectedInsertionFixedAndRepeating count]; i++) {
                [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(i, 0)] should equal(_IP([expectedInsertionFixedAndRepeating[i] integerValue], 0));
            }

            /*
            0            <-- Ad
            1 0  Item A
            2 1  Item B
            3            <-- Ad
            4 2  Item C
             */

            NSArray *expectedInsertionFixedOnly = @[@0, @2, @2];
            for (NSUInteger i = 0; i < [expectedInsertionFixedOnly count]; i++) {
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(i, 0)] should equal(_IP([expectedInsertionFixedOnly[i] integerValue], 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(i, 1)] should equal(_IP([expectedInsertionFixedOnly[i] integerValue], 1));
            }

            // All indices after the last (index, section) should fail.
            NSUInteger lastFixedOnlySection = 1;
            NSUInteger lastFixedOnlyItem = 3;

            for (NSUInteger i = lastFixedOnlyItem + 1; i < 10; ++i) {
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(i, lastFixedOnlySection)] should be_nil;
            }

            for (NSUInteger i = lastFixedOnlySection + 1; i < 10; ++i) {
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0, i)] should be_nil;
            }

            /*
             0  Item A
                        <-- Ad
             1  Item B
                        <-- Ad
             2  Item C
                        <-- Ad
             3  Item D
                        <-- Ad
             4  Item E
                        <-- Ad
             */
            NSArray *expectedInsertionRepeatingOnly = @[@1, @1, @2, @3, @4, @5, @6, @7, @8, @9];
            for (NSUInteger i = 0; i < [expectedInsertionRepeatingOnly count]; i++) {
                [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(i, 0)] should equal(_IP([expectedInsertionRepeatingOnly[i] integerValue], 0));
            }

            /*
             0  Item A
             1  Item B
             2  Item C
             3  Item D
             4  Item E
             */
            for (NSUInteger i = 0; i < 10; i++) {
                [dataWithEmptyPositioning nextAdInsertionIndexPathForAdjustedIndexPath:_IP(i, 0)] should be_nil;
            }
        });
    });

    context(@"inserting an ad", ^{
        beforeEach(^{
            [dataWithFixedAndRepeating insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(4, 0)];
            [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
            [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];
            [dataWithRepeatingOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 0)];
        });

        it(@"should have an adjusted item count equal to the original item count plus the number of inserted ads", ^{
            [dataWithFixedAndRepeating adjustedNumberOfItems:0 inSection:0] should equal(0);
            [dataWithFixedAndRepeating adjustedNumberOfItems:1 inSection:0] should equal(1);
            [dataWithFixedAndRepeating adjustedNumberOfItems:2 inSection:0] should equal(2);
            [dataWithFixedAndRepeating adjustedNumberOfItems:3 inSection:0] should equal(3);
            [dataWithFixedAndRepeating adjustedNumberOfItems:4 inSection:0] should equal(4);
            [dataWithFixedAndRepeating adjustedNumberOfItems:5 inSection:0] should equal(6);
            [dataWithFixedAndRepeating adjustedNumberOfItems:6 inSection:0] should equal(7);
            [dataWithFixedAndRepeating adjustedNumberOfItems:7 inSection:0] should equal(8);
            [dataWithFixedAndRepeating adjustedNumberOfItems:8 inSection:0] should equal(9);
            [dataWithFixedAndRepeating adjustedNumberOfItems:9 inSection:0] should equal(10);
            [dataWithFixedAndRepeating adjustedNumberOfItems:10 inSection:0] should equal(11);

            [dataWithFixedOnly adjustedNumberOfItems:0 inSection:0] should equal(0);
            [dataWithFixedOnly adjustedNumberOfItems:1 inSection:0] should equal(2);
            [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0] should equal(3);
            [dataWithFixedOnly adjustedNumberOfItems:3 inSection:0] should equal(4);
            [dataWithFixedOnly adjustedNumberOfItems:4 inSection:0] should equal(5);
            [dataWithFixedOnly adjustedNumberOfItems:5 inSection:0] should equal(6);
            [dataWithFixedOnly adjustedNumberOfItems:6 inSection:0] should equal(7);
            [dataWithFixedOnly adjustedNumberOfItems:7 inSection:0] should equal(8);
            [dataWithFixedOnly adjustedNumberOfItems:8 inSection:0] should equal(9);
            [dataWithFixedOnly adjustedNumberOfItems:9 inSection:0] should equal(10);
            [dataWithFixedOnly adjustedNumberOfItems:10 inSection:0] should equal(11);
            [dataWithFixedOnly adjustedNumberOfItems:0 inSection:1] should equal(0);
            [dataWithFixedOnly adjustedNumberOfItems:1 inSection:1] should equal(2);
            [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1] should equal(3);
            [dataWithFixedOnly adjustedNumberOfItems:3 inSection:1] should equal(4);
            [dataWithFixedOnly adjustedNumberOfItems:4 inSection:1] should equal(5);
            [dataWithFixedOnly adjustedNumberOfItems:5 inSection:1] should equal(6);
            [dataWithFixedOnly adjustedNumberOfItems:6 inSection:1] should equal(7);
            [dataWithFixedOnly adjustedNumberOfItems:7 inSection:1] should equal(8);
            [dataWithFixedOnly adjustedNumberOfItems:8 inSection:1] should equal(9);
            [dataWithFixedOnly adjustedNumberOfItems:9 inSection:1] should equal(10);
            [dataWithFixedOnly adjustedNumberOfItems:10 inSection:1] should equal(11);

            [dataWithRepeatingOnly adjustedNumberOfItems:0 inSection:0] should equal(0);
            [dataWithRepeatingOnly adjustedNumberOfItems:1 inSection:0] should equal(1);
            [dataWithRepeatingOnly adjustedNumberOfItems:2 inSection:0] should equal(2);
            [dataWithRepeatingOnly adjustedNumberOfItems:3 inSection:0] should equal(3);
            [dataWithRepeatingOnly adjustedNumberOfItems:4 inSection:0] should equal(5);
            [dataWithRepeatingOnly adjustedNumberOfItems:5 inSection:0] should equal(6);
            [dataWithRepeatingOnly adjustedNumberOfItems:6 inSection:0] should equal(7);
            [dataWithRepeatingOnly adjustedNumberOfItems:7 inSection:0] should equal(8);
            [dataWithRepeatingOnly adjustedNumberOfItems:8 inSection:0] should equal(9);
            [dataWithRepeatingOnly adjustedNumberOfItems:9 inSection:0] should equal(10);
            [dataWithRepeatingOnly adjustedNumberOfItems:10 inSection:0] should equal(11);
        });

        it(@"should shift its insertion positions", ^{
            /*

             0  Item A
                        <-- Ad (1)
             1  Item B
                        <-- Ad (2)
             2  Item C
             3  Item D
             4  Ad
             5  Item E
             6  Item F
                        <-- Ad (7)
             7  Item G
             8  Item H
                        <-- Ad (9)
             9  Item I
             10 Item J
                        <-- Ad (11)

             */

            [dataWithFixedAndRepeating previousAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should be_nil;
            [dataWithFixedAndRepeating previousAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should be_nil;
            [dataWithFixedAndRepeating previousAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(1, 0));
            [dataWithFixedAndRepeating previousAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 0)] should equal(_IP(2, 0));
            [dataWithFixedAndRepeating previousAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(2, 0));
            [dataWithFixedAndRepeating previousAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 0)] should equal(_IP(2, 0));
            [dataWithFixedAndRepeating previousAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 0)] should equal(_IP(2, 0));
            [dataWithFixedAndRepeating previousAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 0)] should equal(_IP(2, 0));
            [dataWithFixedAndRepeating previousAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 0)] should equal(_IP(7, 0));
            [dataWithFixedAndRepeating previousAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 0)] should equal(_IP(7, 0));
            [dataWithFixedAndRepeating previousAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 0)] should equal(_IP(9, 0));

            [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should equal(_IP(1, 0));
            [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(1, 0));
            [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(2, 0));
            [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 0)] should equal(_IP(7, 0));
            [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(7, 0));
            [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 0)] should equal(_IP(7, 0));
            [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 0)] should equal(_IP(7, 0));
            [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 0)] should equal(_IP(7, 0));
            [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 0)] should equal(_IP(9, 0));
            [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 0)] should equal(_IP(9, 0));
            [dataWithFixedAndRepeating nextAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 0)] should equal(_IP(11, 0));

            /*
             0  Ad
             1  Item A
             2  Item B
                        <-- Ad (3)
             3  Item C
             4  Item D
             5  Item E
             */

            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should be_nil;
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should be_nil;
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should be_nil;
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 0)] should be_nil;
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 0)] should equal(_IP(3, 0));

            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 0)] should equal(_IP(3, 1));

            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 1)] should be_nil;
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 1)] should be_nil;
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 1)] should be_nil;
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 1)] should be_nil;
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 1)] should equal(_IP(3, 1));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 1)] should equal(_IP(3, 1));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 1)] should equal(_IP(3, 1));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 1)] should equal(_IP(3, 1));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 1)] should equal(_IP(3, 1));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 1)] should equal(_IP(3, 1));
            [dataWithFixedOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 1)] should equal(_IP(3, 1));

            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 0)] should equal(_IP(3, 1));
            [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 0)] should equal(_IP(3, 1));

            /*
             0  Item A
                        <-- Ad (1)
             1  Item B
                        <-- Ad (2)
             2  Item C
             3  Ad
             4  Item D
                        <-- Ad (5)
             5  Item E
                        <-- Ad (6)
             6  Item F
                        <-- Ad (7)
             7  Item G
                        <-- Ad (8)
             */

            [dataWithRepeatingOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should be_nil;
            [dataWithRepeatingOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should be_nil;
            [dataWithRepeatingOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(1, 0));
            [dataWithRepeatingOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 0)] should equal(_IP(2, 0));
            [dataWithRepeatingOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(2, 0));
            [dataWithRepeatingOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 0)] should equal(_IP(2, 0));
            [dataWithRepeatingOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 0)] should equal(_IP(5, 0));
            [dataWithRepeatingOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 0)] should equal(_IP(6, 0));
            [dataWithRepeatingOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 0)] should equal(_IP(7, 0));
            [dataWithRepeatingOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 0)] should equal(_IP(8, 0));
            [dataWithRepeatingOnly previousAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 0)] should equal(_IP(9, 0));

            [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should equal(_IP(1, 0));
            [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(1, 0));
            [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(2, 0));
            [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 0)] should equal(_IP(5, 0));
            [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(5, 0));
            [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 0)] should equal(_IP(5, 0));
            [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 0)] should equal(_IP(6, 0));
            [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 0)] should equal(_IP(7, 0));
            [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 0)] should equal(_IP(8, 0));
            [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 0)] should equal(_IP(9, 0));
            [dataWithRepeatingOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 0)] should equal(_IP(10, 0));
        });

        it(@"should return appropriately adjusted index paths", ^{
            [dataWithFixedAndRepeating adjustedIndexPathForOriginalIndexPath:_IP(0, 0)] should equal(_IP(0, 0));
            [dataWithFixedAndRepeating adjustedIndexPathForOriginalIndexPath:_IP(1, 0)] should equal(_IP(1, 0));
            [dataWithFixedAndRepeating adjustedIndexPathForOriginalIndexPath:_IP(2, 0)] should equal(_IP(2, 0));
            [dataWithFixedAndRepeating adjustedIndexPathForOriginalIndexPath:_IP(3, 0)] should equal(_IP(3, 0));
            [dataWithFixedAndRepeating adjustedIndexPathForOriginalIndexPath:_IP(4, 0)] should equal(_IP(5, 0));
            [dataWithFixedAndRepeating adjustedIndexPathForOriginalIndexPath:_IP(5, 0)] should equal(_IP(6, 0));
            [dataWithFixedAndRepeating adjustedIndexPathForOriginalIndexPath:_IP(6, 0)] should equal(_IP(7, 0));
            [dataWithFixedAndRepeating adjustedIndexPathForOriginalIndexPath:_IP(7, 0)] should equal(_IP(8, 0));
            [dataWithFixedAndRepeating adjustedIndexPathForOriginalIndexPath:_IP(8, 0)] should equal(_IP(9, 0));
            [dataWithFixedAndRepeating adjustedIndexPathForOriginalIndexPath:_IP(9, 0)] should equal(_IP(10, 0));

            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(0, 0)] should equal(_IP(1, 0));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(1, 0)] should equal(_IP(2, 0));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(2, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(3, 0)] should equal(_IP(4, 0));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(4, 0)] should equal(_IP(5, 0));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(5, 0)] should equal(_IP(6, 0));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(6, 0)] should equal(_IP(7, 0));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(7, 0)] should equal(_IP(8, 0));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(8, 0)] should equal(_IP(9, 0));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(9, 0)] should equal(_IP(10, 0));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(0, 1)] should equal(_IP(1, 1));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(1, 1)] should equal(_IP(2, 1));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(2, 1)] should equal(_IP(3, 1));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(3, 1)] should equal(_IP(4, 1));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(4, 1)] should equal(_IP(5, 1));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(5, 1)] should equal(_IP(6, 1));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(6, 1)] should equal(_IP(7, 1));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(7, 1)] should equal(_IP(8, 1));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(8, 1)] should equal(_IP(9, 1));
            [dataWithFixedOnly adjustedIndexPathForOriginalIndexPath:_IP(9, 1)] should equal(_IP(10, 1));

            [dataWithRepeatingOnly adjustedIndexPathForOriginalIndexPath:_IP(0, 0)] should equal(_IP(0, 0));
            [dataWithRepeatingOnly adjustedIndexPathForOriginalIndexPath:_IP(1, 0)] should equal(_IP(1, 0));
            [dataWithRepeatingOnly adjustedIndexPathForOriginalIndexPath:_IP(2, 0)] should equal(_IP(2, 0));
            [dataWithRepeatingOnly adjustedIndexPathForOriginalIndexPath:_IP(3, 0)] should equal(_IP(4, 0));
            [dataWithRepeatingOnly adjustedIndexPathForOriginalIndexPath:_IP(4, 0)] should equal(_IP(5, 0));
            [dataWithRepeatingOnly adjustedIndexPathForOriginalIndexPath:_IP(5, 0)] should equal(_IP(6, 0));
            [dataWithRepeatingOnly adjustedIndexPathForOriginalIndexPath:_IP(6, 0)] should equal(_IP(7, 0));
            [dataWithRepeatingOnly adjustedIndexPathForOriginalIndexPath:_IP(7, 0)] should equal(_IP(8, 0));
            [dataWithRepeatingOnly adjustedIndexPathForOriginalIndexPath:_IP(8, 0)] should equal(_IP(9, 0));
            [dataWithRepeatingOnly adjustedIndexPathForOriginalIndexPath:_IP(9, 0)] should equal(_IP(10, 0));
        });

        it(@"should return appropriate original index paths", ^{
            [dataWithFixedAndRepeating originalIndexPathForAdjustedIndexPath:_IP(0, 0)] should equal(_IP(0, 0));
            [dataWithFixedAndRepeating originalIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(1, 0));
            [dataWithFixedAndRepeating originalIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(2, 0));
            [dataWithFixedAndRepeating originalIndexPathForAdjustedIndexPath:_IP(3, 0)] should equal(_IP(3, 0));
            [dataWithFixedAndRepeating originalIndexPathForAdjustedIndexPath:_IP(4, 0)] should be_nil;
            [dataWithFixedAndRepeating originalIndexPathForAdjustedIndexPath:_IP(5, 0)] should equal(_IP(4, 0));
            [dataWithFixedAndRepeating originalIndexPathForAdjustedIndexPath:_IP(6, 0)] should equal(_IP(5, 0));
            [dataWithFixedAndRepeating originalIndexPathForAdjustedIndexPath:_IP(7, 0)] should equal(_IP(6, 0));
            [dataWithFixedAndRepeating originalIndexPathForAdjustedIndexPath:_IP(8, 0)] should equal(_IP(7, 0));
            [dataWithFixedAndRepeating originalIndexPathForAdjustedIndexPath:_IP(9, 0)] should equal(_IP(8, 0));

            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(0, 0)] should be_nil;
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(0, 0));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(1, 0));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(3, 0)] should equal(_IP(2, 0));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(3, 0));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(5, 0)] should equal(_IP(4, 0));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(6, 0)] should equal(_IP(5, 0));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(7, 0)] should equal(_IP(6, 0));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(8, 0)] should equal(_IP(7, 0));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(9, 0)] should equal(_IP(8, 0));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(0, 1)] should be_nil;
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(1, 1)] should equal(_IP(0, 1));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(2, 1)] should equal(_IP(1, 1));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(3, 1)] should equal(_IP(2, 1));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(4, 1)] should equal(_IP(3, 1));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(5, 1)] should equal(_IP(4, 1));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(6, 1)] should equal(_IP(5, 1));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(7, 1)] should equal(_IP(6, 1));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(8, 1)] should equal(_IP(7, 1));
            [dataWithFixedOnly originalIndexPathForAdjustedIndexPath:_IP(9, 1)] should equal(_IP(8, 1));

            [dataWithRepeatingOnly originalIndexPathForAdjustedIndexPath:_IP(0, 0)] should equal(_IP(0, 0));
            [dataWithRepeatingOnly originalIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(1, 0));
            [dataWithRepeatingOnly originalIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(2, 0));
            [dataWithRepeatingOnly originalIndexPathForAdjustedIndexPath:_IP(3, 0)] should be_nil;
            [dataWithRepeatingOnly originalIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(3, 0));
            [dataWithRepeatingOnly originalIndexPathForAdjustedIndexPath:_IP(5, 0)] should equal(_IP(4, 0));
            [dataWithRepeatingOnly originalIndexPathForAdjustedIndexPath:_IP(6, 0)] should equal(_IP(5, 0));
            [dataWithRepeatingOnly originalIndexPathForAdjustedIndexPath:_IP(7, 0)] should equal(_IP(6, 0));
            [dataWithRepeatingOnly originalIndexPathForAdjustedIndexPath:_IP(8, 0)] should equal(_IP(7, 0));
            [dataWithRepeatingOnly originalIndexPathForAdjustedIndexPath:_IP(9, 0)] should equal(_IP(8, 0));
        });

        it(@"should return ad data for inserted positions", ^{
            for (NSInteger i = 0; i < 10; i++) {
                if (i == 4) {
                    [dataWithFixedAndRepeating adDataAtAdjustedIndexPath:_IP(i, 0)] should_not be_nil;
                    [dataWithFixedAndRepeating isAdAtAdjustedIndexPath:_IP(i, 0)] should be_truthy;
                } else {
                    [dataWithFixedAndRepeating adDataAtAdjustedIndexPath:_IP(i, 0)] should be_nil;
                    [dataWithFixedAndRepeating isAdAtAdjustedIndexPath:_IP(i, 0)] should be_falsy;
                }
            }

            for (NSInteger i = 0; i < 10; i++) {
                if (i == 0) {
                    [dataWithFixedOnly adDataAtAdjustedIndexPath:_IP(i, 0)] should_not be_nil;
                    [dataWithFixedOnly isAdAtAdjustedIndexPath:_IP(i, 0)] should be_truthy;
                    [dataWithFixedOnly adDataAtAdjustedIndexPath:_IP(i, 1)] should_not be_nil;
                    [dataWithFixedOnly isAdAtAdjustedIndexPath:_IP(i, 1)] should be_truthy;
                } else {
                    [dataWithFixedOnly adDataAtAdjustedIndexPath:_IP(i, 0)] should be_nil;
                    [dataWithFixedOnly isAdAtAdjustedIndexPath:_IP(i, 0)] should be_falsy;
                    [dataWithFixedOnly adDataAtAdjustedIndexPath:_IP(i, 1)] should be_nil;
                    [dataWithFixedOnly isAdAtAdjustedIndexPath:_IP(i, 1)] should be_falsy;

                }
            }

            for (NSInteger i = 0; i < 10; i++) {
                if (i == 3) {
                    [dataWithRepeatingOnly adDataAtAdjustedIndexPath:_IP(i, 0)] should_not be_nil;
                    [dataWithRepeatingOnly isAdAtAdjustedIndexPath:_IP(i, 0)] should be_truthy;
                } else {
                    [dataWithRepeatingOnly adDataAtAdjustedIndexPath:_IP(i, 0)] should be_nil;
                    [dataWithRepeatingOnly isAdAtAdjustedIndexPath:_IP(i, 0)] should be_falsy;
                }
            }
        });
    });

    context(@"attempting to insert an ad at a position that is not desired", ^{
        beforeEach(^{
            [dataWithEmptyPositioning insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
        });

        it(@"should have an adjusted item count equal to the original item count", ^{
            NSArray *counts = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
            for (NSUInteger i = 0; i < [counts count]; i++) {
                [dataWithEmptyPositioning adjustedNumberOfItems:i inSection:0] should equal([counts[i] integerValue]);
            }
        });

        it(@"should return adjusted index paths that are the same as the original index paths", ^{
            NSArray *counts = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
            for (NSUInteger i = 0; i < [counts count]; i++) {
                [dataWithEmptyPositioning adjustedIndexPathForOriginalIndexPath:_IP(i, 0)] should equal(_IP([counts[i] integerValue], 0));
            }
        });

        it(@"should return correct insertion positions according to its positioning object", ^{
            for (NSUInteger i = 0; i < 10; i++) {
                [dataWithEmptyPositioning nextAdInsertionIndexPathForAdjustedIndexPath:_IP(i, 0)] should be_nil;
            }
        });
    });

    context(@"responding to content insertions", ^{
        __block MPStreamAdPlacementData *placementData;

        beforeEach(^{
            MPClientAdPositioning *positioning = [MPClientAdPositioning positioning];
            [positioning addFixedIndexPath:_IP(0, 0)];
            [positioning addFixedIndexPath:_IP(3, 1)];
            [positioning addFixedIndexPath:_IP(6, 1)];
            [positioning enableRepeatingPositionsWithInterval:6];

            placementData = [[MPStreamAdPlacementData alloc] initWithPositioning:positioning];

            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 1)];

            [placementData insertItemsAtIndexPaths:@[_IP(3, 1), _IP(0, 0)]];
        });

        it(@"should have an adjusted item count equal to the original item count plus the number of inserted ads", ^{
            [placementData adjustedNumberOfItems:0 inSection:0] should equal(0);
            [placementData adjustedNumberOfItems:1 inSection:0] should equal(1);
            [placementData adjustedNumberOfItems:2 inSection:0] should equal(3);


            [placementData adjustedNumberOfItems:0 inSection:1] should equal(0);
            [placementData adjustedNumberOfItems:1 inSection:1] should equal(1);
            [placementData adjustedNumberOfItems:2 inSection:1] should equal(2);
            [placementData adjustedNumberOfItems:3 inSection:1] should equal(3);
            [placementData adjustedNumberOfItems:4 inSection:1] should equal(4);
            [placementData adjustedNumberOfItems:5 inSection:1] should equal(6);
            [placementData adjustedNumberOfItems:6 inSection:1] should equal(7);
            [placementData adjustedNumberOfItems:7 inSection:1] should equal(8);
            [placementData adjustedNumberOfItems:8 inSection:1] should equal(9);
            [placementData adjustedNumberOfItems:9 inSection:1] should equal(10);
            [placementData adjustedNumberOfItems:10 inSection:1] should equal(11);
        });

        it(@"should shift its insertion positions", ^{
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should be_nil;


            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 1)] should equal(_IP(7, 1));
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 1)] should equal(_IP(7, 1));
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 1)] should equal(_IP(7, 1));

            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should equal(_IP(7, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(7, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(7, 1));

            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 1)] should equal(_IP(7, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 1)] should equal(_IP(7, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 1)] should equal(_IP(7, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 1)] should equal(_IP(7, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 1)] should equal(_IP(7, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 1)] should equal(_IP(7, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 1)] should equal(_IP(7, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 1)] should equal(_IP(7, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 1)] should equal(_IP(12, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 1)] should equal(_IP(12, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 1)] should equal(_IP(12, 1));
        });

        it(@"should return appropriately adjusted index paths", ^{
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(0, 0)] should equal(_IP(0, 0));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(1, 0)] should equal(_IP(2, 0));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(2, 0)] should equal(_IP(3, 0));

            [placementData adjustedIndexPathForOriginalIndexPath:_IP(0, 1)] should equal(_IP(0, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(1, 1)] should equal(_IP(1, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(2, 1)] should equal(_IP(2, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(3, 1)] should equal(_IP(3, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(4, 1)] should equal(_IP(5, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(5, 1)] should equal(_IP(6, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(6, 1)] should equal(_IP(7, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(7, 1)] should equal(_IP(8, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(8, 1)] should equal(_IP(9, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(9, 1)] should equal(_IP(10, 1));
        });

        it(@"should return appropriate original index paths", ^{
            [placementData originalIndexPathForAdjustedIndexPath:_IP(0, 0)] should equal(_IP(0, 0));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(1, 0)] should be_nil;
            [placementData originalIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(1, 0));

            [placementData originalIndexPathForAdjustedIndexPath:_IP(0, 1)] should equal(_IP(0, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(1, 1)] should equal(_IP(1, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(2, 1)] should equal(_IP(2, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(3, 1)] should equal(_IP(3, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(4, 1)] should be_nil;
            [placementData originalIndexPathForAdjustedIndexPath:_IP(5, 1)] should equal(_IP(4, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(6, 1)] should equal(_IP(5, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(7, 1)] should equal(_IP(6, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(8, 1)] should equal(_IP(7, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(9, 1)] should equal(_IP(8, 1));
        });

        it(@"should return ad data for inserted positions", ^{
            for (NSInteger i = 0; i < 10; i++) {
                if (i == 4) {
                    [placementData adDataAtAdjustedIndexPath:_IP(i, 1)] should_not be_nil;
                    [placementData isAdAtAdjustedIndexPath:_IP(i, 1)] should be_truthy;
                } else {
                    [placementData adDataAtAdjustedIndexPath:_IP(i, 1)] should be_nil;
                    [placementData isAdAtAdjustedIndexPath:_IP(i, 1)] should be_falsy;
                }

                if (i == 1) {
                    [placementData adDataAtAdjustedIndexPath:_IP(i, 0)] should_not be_nil;
                    [placementData isAdAtAdjustedIndexPath:_IP(i, 0)] should be_truthy;
                } else {
                    [placementData adDataAtAdjustedIndexPath:_IP(i, 0)] should be_nil;
                    [placementData isAdAtAdjustedIndexPath:_IP(i, 0)] should be_falsy;
                }
            }
        });
    });

//    context(@"clearing ads", ^{
//        __block MPStreamAdPlacementData *placementData;
//
//        beforeEach(^{
//            MPClientAdPositioning *positioning = [MPClientAdPositioning positioning];
//            [positioning addFixedIndexPath:_IP(3, 0)];
//            [positioning addFixedIndexPath:_IP(6, 0)];
//            [positioning addFixedIndexPath:_IP(3, 1)];
//            [positioning addFixedIndexPath:_IP(6, 1)];
//
//            placementData = [[MPStreamAdPlacementData alloc] initWithPositioning:positioning];
//        });
//
//        it(@"should have the same placement data before inserting all ads and after clearing all ads.", ^{
//
//            NSArray *desiredOriginalPathsSectionZero = [placementData desiredOriginalAdIndexPathsForSection:0];
//            NSArray *desiredOriginalPathsSectionOne = [placementData desiredOriginalAdIndexPathsForSection:1];
//            NSArray *desiredInsertionPathsSectionZero = [placementData desiredInsertionAdIndexPathsForSection:0];
//            NSArray *desiredInsertionPathsSectionOne = [placementData desiredInsertionAdIndexPathsForSection:1];
//
//            [placementData originalAdIndexPathsForSection:0] should be_empty;
//            [placementData adjustedAdIndexPathsForSection:1] should be_empty;
//            [placementData originalAdIndexPathsForSection:0] should be_empty;
//            [placementData adjustedAdIndexPathsForSection:1] should be_empty;
//
//            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 0)];
//            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(6, 0)];
//            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 1)];
//            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(6, 1)];
//
//            [placementData desiredInsertionAdIndexPathsForSection:0] should be_empty;
//            [placementData desiredOriginalAdIndexPathsForSection:1] should be_empty;
//            [placementData desiredInsertionAdIndexPathsForSection:0] should be_empty;
//            [placementData desiredOriginalAdIndexPathsForSection:1] should be_empty;
//
//            [placementData originalAdIndexPathsForSection:0] should_not be_empty;
//            [placementData adjustedAdIndexPathsForSection:1] should_not be_empty;
//            [placementData originalAdIndexPathsForSection:0] should_not be_empty;
//            [placementData adjustedAdIndexPathsForSection:1] should_not be_empty;
//
//            [placementData clearAdsInAdjustedRange:NSMakeRange(0, NSIntegerMax) inSection:0];
//            [placementData clearAdsInAdjustedRange:NSMakeRange(0, NSIntegerMax) inSection:1];
//
//            desiredOriginalPathsSectionZero should equal([placementData desiredOriginalAdIndexPathsForSection:0]);
//            desiredOriginalPathsSectionOne should equal([placementData desiredOriginalAdIndexPathsForSection:1]);
//            desiredInsertionPathsSectionZero should equal([placementData desiredInsertionAdIndexPathsForSection:0]);
//            desiredInsertionPathsSectionOne should equal([placementData desiredInsertionAdIndexPathsForSection:1]);
//
//            [placementData originalAdIndexPathsForSection:0] should be_empty;
//            [placementData adjustedAdIndexPathsForSection:1] should be_empty;
//            [placementData originalAdIndexPathsForSection:0] should be_empty;
//            [placementData adjustedAdIndexPathsForSection:1] should be_empty;
//        });
//    });

    context(@"getting ad index paths in range", ^{
        __block MPStreamAdPlacementData *placementData;

        beforeEach(^{
            MPClientAdPositioning *positioning = [MPClientAdPositioning positioning];
            [positioning addFixedIndexPath:_IP(3, 0)];
            [positioning addFixedIndexPath:_IP(6, 0)];
            [positioning addFixedIndexPath:_IP(3, 1)];
            [positioning addFixedIndexPath:_IP(6, 1)];

            placementData = [[MPStreamAdPlacementData alloc] initWithPositioning:positioning];
        });

        it(@"should return the adjusted index paths of placed ads in range", ^{
            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 0)];
            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(6, 0)];
            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 1)];
            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(6, 1)];

            NSArray *indexPaths = [placementData adjustedAdIndexPathsInAdjustedRange:NSMakeRange(0, [placementData adjustedNumberOfItems:7 inSection:0]) inSection:0];

            indexPaths should contain(_IP(3, 0));
            indexPaths should contain(_IP(6, 0));
            [indexPaths count] should equal(2);
        });
    });

    context(@"responding to content deletions", ^{
        __block MPStreamAdPlacementData *placementData;

        beforeEach(^{
            MPClientAdPositioning *positioning = [MPClientAdPositioning positioning];
            [positioning addFixedIndexPath:_IP(3, 0)];
            [positioning addFixedIndexPath:_IP(6, 0)];
            [positioning addFixedIndexPath:_IP(3, 1)];
            [positioning addFixedIndexPath:_IP(6, 1)];
            [positioning enableRepeatingPositionsWithInterval:6];

            placementData = [[MPStreamAdPlacementData alloc] initWithPositioning:positioning];

            // Insert two ads.

            /*
             0  Item A
             1  Item B
             2  Item C
             3  Ad

             0  Item A
             1  Item B
             2  Item C
             3  Ad
             4  Item D
             5  Item E
             6  Item F
             7  Item G
             8  Item H
             9  Item I
             10 Item J
             11 Ad
             12 Item K
             */
            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 0)];
            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 1)];
            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(11, 1)];

            // Delete all the content items between those two ads (items 3 through 9).

            /*
             0  Ad
             1  Item D
             2  Item E
             3  Item F

             0  Item A
             1  Item B
             2  Item C
             3  Ad
             4  Ad
             5  Item K
             */

            NSMutableArray *contentItemsToDelete = [NSMutableArray array];
            for (NSUInteger item = 4; item <= 9; item++) {
                [contentItemsToDelete addObject:_IP(item, 1)];
            }
            [contentItemsToDelete addObject:_IP(3, 1)];
            [contentItemsToDelete addObject:_IP(0, 0)];
            [contentItemsToDelete addObject:_IP(1, 0)];
            [contentItemsToDelete addObject:_IP(2, 0)];

            [placementData deleteItemsAtIndexPaths:contentItemsToDelete];
        });

        it(@"should have an adjusted item count equal to the original item count plus the number of inserted ads", ^{
            [placementData adjustedNumberOfItems:0 inSection:0] should equal(0);
            [placementData adjustedNumberOfItems:1 inSection:0] should equal(2);
            [placementData adjustedNumberOfItems:2 inSection:0] should equal(3);

            [placementData adjustedNumberOfItems:0 inSection:1] should equal(0);
            [placementData adjustedNumberOfItems:1 inSection:1] should equal(1);
            [placementData adjustedNumberOfItems:2 inSection:1] should equal(2);
            [placementData adjustedNumberOfItems:3 inSection:1] should equal(3);
            [placementData adjustedNumberOfItems:4 inSection:1] should equal(6);
            [placementData adjustedNumberOfItems:5 inSection:1] should equal(7);
            [placementData adjustedNumberOfItems:6 inSection:1] should equal(8);
            [placementData adjustedNumberOfItems:7 inSection:1] should equal(9);
            [placementData adjustedNumberOfItems:8 inSection:1] should equal(10);
            [placementData adjustedNumberOfItems:9 inSection:1] should equal(11);
            [placementData adjustedNumberOfItems:10 inSection:1] should equal(12);
        });

        it(@"should shift its insertion positions", ^{
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(3, 0));

            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 1)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 1)] should equal(_IP(4, 1));
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 1)] should equal(_IP(4, 1));
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 1)] should equal(_IP(4, 1));
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 1)] should equal(_IP(4, 1));
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 1)] should equal(_IP(4, 1));
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 1)] should equal(_IP(4, 1));

            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should equal(_IP(3, 0));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(3, 0));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(3, 0));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 0)] should equal(_IP(3, 0));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(4, 1));

            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 1)] should equal(_IP(4, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 1)] should equal(_IP(4, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 1)] should equal(_IP(4, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 1)] should equal(_IP(4, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 1)] should equal(_IP(4, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 1)] should equal(_IP(10, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 1)] should equal(_IP(10, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(7, 1)] should equal(_IP(10, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(8, 1)] should equal(_IP(10, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(9, 1)] should equal(_IP(10, 1));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(10, 1)] should equal(_IP(10, 1));
        });

        it(@"should return appropriately adjusted index paths", ^{
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(0, 0)] should equal(_IP(1, 0));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(1, 0)] should equal(_IP(2, 0));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(2, 0)] should equal(_IP(3, 0));

            [placementData adjustedIndexPathForOriginalIndexPath:_IP(0, 1)] should equal(_IP(0, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(1, 1)] should equal(_IP(1, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(2, 1)] should equal(_IP(2, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(3, 1)] should equal(_IP(5, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(4, 1)] should equal(_IP(6, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(5, 1)] should equal(_IP(7, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(6, 1)] should equal(_IP(8, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(7, 1)] should equal(_IP(9, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(8, 1)] should equal(_IP(10, 1));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(9, 1)] should equal(_IP(11, 1));
        });

        it(@"should return appropriate original index paths", ^{
            [placementData originalIndexPathForAdjustedIndexPath:_IP(0, 0)] should be_nil;
            [placementData originalIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(0, 0));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(1, 0));

            [placementData originalIndexPathForAdjustedIndexPath:_IP(0, 1)] should equal(_IP(0, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(1, 1)] should equal(_IP(1, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(2, 1)] should equal(_IP(2, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(3, 1)] should be_nil;
            [placementData originalIndexPathForAdjustedIndexPath:_IP(4, 1)] should be_nil;
            [placementData originalIndexPathForAdjustedIndexPath:_IP(5, 1)] should equal(_IP(3, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(6, 1)] should equal(_IP(4, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(7, 1)] should equal(_IP(5, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(8, 1)] should equal(_IP(6, 1));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(9, 1)] should equal(_IP(7, 1));
        });

        it(@"should return ad data for inserted positions", ^{
            for (NSInteger i = 0; i < 10; i++) {
                if (i == 0) {
                    [placementData adDataAtAdjustedIndexPath:_IP(i, 0)] should_not be_nil;
                    [placementData isAdAtAdjustedIndexPath:_IP(i, 0)] should be_truthy;
                } else {
                    [placementData adDataAtAdjustedIndexPath:_IP(i, 0)] should be_nil;
                    [placementData isAdAtAdjustedIndexPath:_IP(i, 0)] should be_falsy;
                }

                if (i == 3 || i == 4) {
                    [placementData adDataAtAdjustedIndexPath:_IP(i, 1)] should_not be_nil;
                    [placementData isAdAtAdjustedIndexPath:_IP(i, 1)] should be_truthy;
                } else {
                    [placementData adDataAtAdjustedIndexPath:_IP(i, 1)] should be_nil;
                    [placementData isAdAtAdjustedIndexPath:_IP(i, 1)] should be_falsy;
                }
            }
        });
    });

    context(@"moving content items", ^{
        __block MPStreamAdPlacementData *placementData;

        beforeEach(^{
            MPClientAdPositioning *positioning = [MPClientAdPositioning positioning];
            [positioning addFixedIndexPath:_IP(3, 0)];
            [positioning addFixedIndexPath:_IP(5, 0)];

            placementData = [[MPStreamAdPlacementData alloc] initWithPositioning:positioning];

            /*
             0  Item A
             1  Item B
             2  Item C
             3  Ad
             4  Item D
             5  Item E
                       <-- Ad (5)
             */
            [placementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 0)];

            [placementData moveItemAtIndexPath:_IP(2, 0) toIndexPath:_IP(3, 0)];

            /*
             0  Item A
             1  Item B
             2  Ad
             3  Item C
             4  Item D
             5  Item E
                        <-- Ad (5)
             */
        });

        it(@"should have an adjusted item count equal to the original item count plus the number of inserted ads", ^{
            [placementData adjustedNumberOfItems:0 inSection:0] should equal(0);
            [placementData adjustedNumberOfItems:1 inSection:0] should equal(1);
            [placementData adjustedNumberOfItems:2 inSection:0] should equal(2);
            [placementData adjustedNumberOfItems:3 inSection:0] should equal(4);
            [placementData adjustedNumberOfItems:4 inSection:0] should equal(5);
        });

        it(@"should shift its insertion positions", ^{
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 0)] should be_nil;
            [placementData previousAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 0)] should equal(_IP(5, 0));

            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0, 0)] should equal(_IP(5, 0));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(5, 0));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2, 0)] should equal(_IP(5, 0));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3, 0)] should equal(_IP(5, 0));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(5, 0));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(5, 0)] should equal(_IP(5, 0));
            [placementData nextAdInsertionIndexPathForAdjustedIndexPath:_IP(6, 0)] should be_nil;
        });

        it(@"should return appropriately adjusted index paths", ^{
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(0, 0)] should equal(_IP(0, 0));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(1, 0)] should equal(_IP(1, 0));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(2, 0)] should equal(_IP(3, 0));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(3, 0)] should equal(_IP(4, 0));
            [placementData adjustedIndexPathForOriginalIndexPath:_IP(4, 0)] should equal(_IP(5, 0));

        });

        it(@"should return appropriate original index paths", ^{
            [placementData originalIndexPathForAdjustedIndexPath:_IP(0, 0)] should equal(_IP(0, 0));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(1, 0)] should equal(_IP(1, 0));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(2, 0)] should be_nil;
            [placementData originalIndexPathForAdjustedIndexPath:_IP(3, 0)] should equal(_IP(2, 0));
            [placementData originalIndexPathForAdjustedIndexPath:_IP(4, 0)] should equal(_IP(3, 0));

        });

        it(@"should return ad data for inserted positions", ^{
            for (NSInteger i = 0; i < 10; i++) {
                if (i == 2) {
                    [placementData adDataAtAdjustedIndexPath:_IP(i, 0)] should_not be_nil;
                    [placementData isAdAtAdjustedIndexPath:_IP(i, 0)] should be_truthy;
                } else {
                    [placementData adDataAtAdjustedIndexPath:_IP(i, 0)] should be_nil;
                    [placementData isAdAtAdjustedIndexPath:_IP(i, 0)] should be_falsy;
                }
            }
        });
    });

    describe(@"-insertSections:", ^{
        context(@"when inserting 1 section at the beginning", ^{
            __block NSMutableIndexSet *insertionSet;
            beforeEach(^{
                insertionSet = [NSMutableIndexSet indexSet];
                [insertionSet addIndex:0];
            });

            it(@"should not have any ads in the inserted section", ^{
                [dataWithFixedOnly insertSections:insertionSet];
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 1));
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:0] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:0] should equal(3);
            });

            it(@"should have incremented section for the ad positions by 1", ^{
                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,1)] should equal(_IP(2, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,1)] should equal(_IP(0, 2));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,2)] should equal(_IP(0, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,2)] should equal(_IP(2, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,2)] should be_nil;
            });

            it(@"should have incremented the number of items for the sections' new positions", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];

                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0];
                NSUInteger oldSection2 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:1];

                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:2] should equal(oldSection2);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:3] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:3] should equal(2);

                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:3] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:3] should equal(2);
            });
        });

        context(@"when inserting 1 section at the end", ^{
            __block NSMutableIndexSet *insertionSet;
            beforeEach(^{
                insertionSet = [NSMutableIndexSet indexSet];
                [insertionSet addIndex:2];
            });

            it(@"should not have any ads in the inserted section", ^{
                [dataWithFixedOnly insertSections:insertionSet];
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,2)] should be_nil;
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:2] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:2] should equal(2);
            });

            it(@"should have not moved any of the original ad positions", ^{
                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,0)] should equal(_IP(2, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,0)] should equal(_IP(0, 1));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,1)] should equal(_IP(2, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,1)] should be_nil;
            });

            it(@"should have not adjusted any counts for the original sections", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];

                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0];
                NSUInteger oldSection2 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:1];

                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:1] should equal(oldSection2);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:3] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:3] should equal(2);

                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:3] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:3] should equal(2);
            });
        });

        context(@"when inserting consecutive sections", ^{
            __block NSMutableIndexSet *insertionSet;
            beforeEach(^{
                insertionSet = [NSMutableIndexSet indexSet];
                [insertionSet addIndex:1];
                [insertionSet addIndex:0];
            });

            it(@"should not have any ads in the inserted sections", ^{
                [dataWithFixedOnly insertSections:insertionSet];
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 2));
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:1] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:4 inSection:1] should equal(4);

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 2));
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:0] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:0] should equal(3);
            });

            it(@"should have moved the ad positions ahead by 2 sections", ^{
                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,2)] should equal(_IP(0, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,2)] should equal(_IP(2, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,2)] should equal(_IP(0, 3));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,3)] should equal(_IP(0, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,3)] should equal(_IP(2, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,3)] should be_nil;
            });

            it(@"should have updated the adjusted counts for the original sections in their new locations", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];

                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0];
                NSUInteger oldSection2 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:1];

                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:2] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:3] should equal(oldSection2);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);

                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);
            });
        });

        context(@"when inserting non-consecutive sections", ^{
            __block NSMutableIndexSet *insertionSet;
            beforeEach(^{
                insertionSet = [NSMutableIndexSet indexSet];
                [insertionSet addIndex:2];
                [insertionSet addIndex:0];
            });

            it(@"should not have any ads in the inserted sections", ^{
                [dataWithFixedOnly insertSections:insertionSet];
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,2)] should equal(_IP(0, 3));
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:2] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:7 inSection:2] should equal(7);

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 1));
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:0] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:8 inSection:0] should equal(8);
            });

            it(@"should have shifted the original ad positions ahead correctly", ^{
                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,1)] should equal(_IP(2, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,1)] should equal(_IP(0, 3));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,3)] should equal(_IP(0, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,3)] should equal(_IP(2, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,3)] should be_nil;
            });

            it(@"should have updated the adjusted counts for the original sections in their new locations", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];

                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0];
                NSUInteger oldSection2 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:1];

                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:3] should equal(oldSection2);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);

                [dataWithFixedOnly insertSections:insertionSet];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);
            });
        });
    });

    context(@"-deleteSections", ^{
        context(@"when deleting 1 section at the beginning", ^{
            __block NSMutableIndexSet *deletionSet;
            beforeEach(^{
                deletionSet = [NSMutableIndexSet indexSet];
                [deletionSet addIndex:0];
            });

            it(@"should have decremented the undeleted ad positions' sections by 1", ^{
                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,0)] should equal(_IP(2, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,0)] should be_nil;
            });

            it(@"should adjust the counts for the sections", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];

                NSUInteger oldSection = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1];

                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0] should equal(oldSection);
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:1] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1] should equal(2);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:3] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:3] should equal(2);

                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:3] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:3] should equal(2);
            });
        });

        context(@"when deleting 1 section at the end", ^{
            __block NSMutableIndexSet *deletionSet;
            beforeEach(^{
                deletionSet = [NSMutableIndexSet indexSet];
                [deletionSet addIndex:1];
            });

            it(@"should have only removed ad positions at the last section", ^{
                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,0)] should equal(_IP(2, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,0)] should be_nil;
            });

            it(@"should have not adjusted any counts for the undeleted section", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];

                NSUInteger oldSection = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0];

                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0] should equal(oldSection);
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:1] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1] should equal(2);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:3] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:3] should equal(2);

                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:3] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:3] should equal(2);
            });
        });

        context(@"when deleting consecutive sections", ^{
            __block NSMutableIndexSet *deletionSet;

            beforeEach(^{
                MPClientAdPositioning *fixedOnlyPositioning = [MPClientAdPositioning positioning];
                [fixedOnlyPositioning addFixedIndexPath:_IP(0, 0)];
                [fixedOnlyPositioning addFixedIndexPath:_IP(3, 0)];

                [fixedOnlyPositioning addFixedIndexPath:_IP(0, 1)];
                [fixedOnlyPositioning addFixedIndexPath:_IP(3, 1)];

                [fixedOnlyPositioning addFixedIndexPath:_IP(0, 2)];
                [fixedOnlyPositioning addFixedIndexPath:_IP(3, 2)];

                [fixedOnlyPositioning addFixedIndexPath:_IP(0, 3)];
                [fixedOnlyPositioning addFixedIndexPath:_IP(3, 3)];

                dataWithFixedOnly = [[MPStreamAdPlacementData alloc] initWithPositioning:fixedOnlyPositioning];

                deletionSet = [NSMutableIndexSet indexSet];
                [deletionSet addIndex:1];
                [deletionSet addIndex:2];
            });

            it(@"should have shifted the ad positions at the last section while not shifting the first section's", ^{
                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,0)] should equal(_IP(2, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,0)] should equal(_IP(0, 1));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,1)] should equal(_IP(2, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,1)] should be_nil;
            });

            it(@"should have updated the adjusted counts for the original sections in their new locations", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 3)];

                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0];
                NSUInteger oldSection2 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:3];

                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:1] should equal(oldSection2);

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:2] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:2] should equal(2);

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:3] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:3] should equal(2);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);

                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);
            });
        });

        context(@"when deleting non-consecutive sections", ^{
            __block NSMutableIndexSet *deletionSet;

            beforeEach(^{
                MPClientAdPositioning *fixedOnlyPositioning = [MPClientAdPositioning positioning];
                [fixedOnlyPositioning addFixedIndexPath:_IP(0, 0)];
                [fixedOnlyPositioning addFixedIndexPath:_IP(3, 0)];

                [fixedOnlyPositioning addFixedIndexPath:_IP(0, 1)];
                [fixedOnlyPositioning addFixedIndexPath:_IP(2, 1)];

                [fixedOnlyPositioning addFixedIndexPath:_IP(0, 2)];
                [fixedOnlyPositioning addFixedIndexPath:_IP(1, 2)];

                [fixedOnlyPositioning addFixedIndexPath:_IP(0, 3)];
                [fixedOnlyPositioning addFixedIndexPath:_IP(3, 3)];

                dataWithFixedOnly = [[MPStreamAdPlacementData alloc] initWithPositioning:fixedOnlyPositioning];

                deletionSet = [NSMutableIndexSet indexSet];
                [deletionSet addIndex:2];
                [deletionSet addIndex:0];
            });

            it(@"should have shifted the original ad positions for undeleted sections", ^{
                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,0)] should equal(_IP(1, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,0)] should equal(_IP(0, 1));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,1)] should equal(_IP(2, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,1)] should be_nil;
            });

            it(@"should have updated the adjusted counts for the original sections in their new locations", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 3)];

                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1];
                NSUInteger oldSection3 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:3];

                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:0] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:1] should equal(oldSection3);

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:2] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:8 inSection:2] should equal(8);

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:3] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:9 inSection:3] should equal(9);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);

                [dataWithFixedOnly deleteSections:deletionSet];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);
            });
        });
    });

    describe(@"-moveSection:toSection:", ^{
        __block NSUInteger fromSection;
        __block NSUInteger toSection;

        beforeEach(^{
            MPClientAdPositioning *fixedOnlyPositioning = [MPClientAdPositioning positioning];
            [fixedOnlyPositioning addFixedIndexPath:_IP(0, 0)];
            [fixedOnlyPositioning addFixedIndexPath:_IP(4, 0)];

            [fixedOnlyPositioning addFixedIndexPath:_IP(0, 1)];
            [fixedOnlyPositioning addFixedIndexPath:_IP(3, 1)];

            [fixedOnlyPositioning addFixedIndexPath:_IP(0, 2)];
            [fixedOnlyPositioning addFixedIndexPath:_IP(2, 2)];

            [fixedOnlyPositioning addFixedIndexPath:_IP(0, 3)];
            [fixedOnlyPositioning addFixedIndexPath:_IP(2, 3)];

            dataWithFixedOnly = [[MPStreamAdPlacementData alloc] initWithPositioning:fixedOnlyPositioning];
        });

        context(@"when moving the first section to a middle section", ^{
            beforeEach(^{
                fromSection = 0;
                toSection = 2;
            });

            it(@"should have moved fromSection's ad positioning to toSection's ad positioning", ^{
                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,2)] should equal(_IP(0, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,2)] should equal(_IP(3, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4,2)] should equal(_IP(0, 3));
            });

            it(@"should make it such that toSection's adjusted count is now what fromSection's was prior to the move", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, fromSection)];
                NSUInteger fromSectionCount = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:fromSection];

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:toSection] should equal(fromSectionCount);
            });

            it(@"should have shifted the ad positions of the other sections (not involved in the move) correctly", ^{
                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,0)] should equal(_IP(2, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,0)] should equal(_IP(0, 1));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,1)] should equal(_IP(1, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,1)] should equal(_IP(0, 2));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,3)] should equal(_IP(0, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,3)] should equal(_IP(1, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2,3)] should be_nil;
            });

            it(@"should have shifted the adjusted counts of the other sections (not involved in the move) correctly", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 2)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 3)];

                // The count at section 1 should match the count at section 0 after deletion.
                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:1 inSection:1];
                NSUInteger oldSection2 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:2];
                NSUInteger oldSection3 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:3];

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:1 inSection:0] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1] should equal(oldSection2);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:3] should equal(oldSection3);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);
            });
        });

        context(@"when moving the first section to the last section", ^{
            beforeEach(^{
                fromSection = 0;
                toSection = 3;
            });

            it(@"should have moved fromSection's ad positioning to toSection's ad positioning", ^{
                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,3)] should equal(_IP(0, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,3)] should equal(_IP(3, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4,3)] should be_nil;
            });

            it(@"should make it such that toSection's adjusted count is now what fromSection's was prior to the move", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, fromSection)];
                NSUInteger fromSectionCount = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:fromSection];

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:toSection] should equal(fromSectionCount);
            });

            it(@"should have shifted the ad positions of the other sections (not involved in the move) correctly", ^{
                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,0)] should equal(_IP(2, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,0)] should equal(_IP(0, 1));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,1)] should equal(_IP(1, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,1)] should equal(_IP(0, 2));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,2)] should equal(_IP(0, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,2)] should equal(_IP(1, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2,2)] should equal(_IP(0, 3));
            });

            it(@"should have shifted the adjusted counts of the other sections (not involved in the move) correctly", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 2)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 3)];

                // The count at section 1 should match the count at section 0 after deletion.
                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:1 inSection:1];
                NSUInteger oldSection2 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:2];
                NSUInteger oldSection3 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:3];

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:1 inSection:0] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1] should equal(oldSection2);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:2] should equal(oldSection3);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);
            });
        });

        context(@"when moving the last section to the first section", ^{
            beforeEach(^{
                fromSection = 3;
                toSection = 0;
            });

            it(@"should have moved fromSection's ad positioning to toSection's ad positioning", ^{
                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,0)] should equal(_IP(1, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4,0)] should equal(_IP(0, 1));
            });

            it(@"should make it such that toSection's adjusted count is now what fromSection's was prior to the move", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, fromSection)];
                NSUInteger fromSectionCount = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:fromSection];

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:toSection] should equal(fromSectionCount);
            });

            it(@"should have shifted the ad positions of the other sections (not involved in the move) correctly", ^{
                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,1)] should equal(_IP(3, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4,1)] should equal(_IP(0, 2));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,2)] should equal(_IP(0, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,2)] should equal(_IP(2, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,2)] should equal(_IP(0, 3));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,3)] should equal(_IP(0, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,3)] should equal(_IP(1, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2,3)] should be_nil;
            });

            it(@"should have shifted the adjusted counts of the other sections (not involved in the move) correctly", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 2)];

                // The count at section 1 should match the count at section 0 after deletion.
                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:1 inSection:0];
                NSUInteger oldSection2 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1];
                NSUInteger oldSection3 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:2];

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:1 inSection:1] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:2] should equal(oldSection2);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:3] should equal(oldSection3);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);
            });
        });

        context(@"when moving the last section to a middle section", ^{
            beforeEach(^{
                fromSection = 3;
                toSection = 2;
            });

            it(@"should have moved fromSection's ad positioning to toSection's ad positioning", ^{
                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,2)] should equal(_IP(0, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,2)] should equal(_IP(1, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4,2)] should equal(_IP(0, 3));
            });

            it(@"should make it such that toSection's adjusted count is now what fromSection's was prior to the move", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, fromSection)];
                NSUInteger fromSectionCount = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:fromSection];

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:toSection] should equal(fromSectionCount);
            });

            it(@"should have shifted the ad positions of the other sections (not involved in the move) correctly", ^{
                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,0)] should equal(_IP(3, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4,0)] should equal(_IP(0, 1));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,1)] should equal(_IP(2, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,1)] should equal(_IP(0, 2));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,3)] should equal(_IP(0, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,3)] should equal(_IP(1, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2,3)] should be_nil;
            });

            it(@"should have shifted the adjusted counts of the other sections (not involved in the move) correctly", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 2)];

                // The count at section 1 should match the count at section 0 after deletion.
                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:1 inSection:0];
                NSUInteger oldSection2 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1];
                NSUInteger oldSection3 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:2];

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:1 inSection:0] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1] should equal(oldSection2);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:3] should equal(oldSection3);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);
            });
        });

        context(@"when moving the section to the same section", ^{
            beforeEach(^{
                fromSection = 1;
                toSection = 1;
            });

            it(@"should have not affected the ad positions", ^{
                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,0)] should equal(_IP(3, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4,0)] should equal(_IP(0, 1));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,1)] should equal(_IP(2, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,1)] should equal(_IP(0, 2));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,2)] should equal(_IP(0, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,2)] should equal(_IP(1, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2,2)] should equal(_IP(0, 3));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,3)] should equal(_IP(0, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,3)] should equal(_IP(1, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2,3)] should be_nil;
            });

            it(@"should have not affected the adjusted counts", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 1)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 2)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 3)];

                // The count at section 1 should match the count at section 0 after deletion.
                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:1 inSection:0];
                NSUInteger oldSection2 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1];
                NSUInteger oldSection3 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:2];
                NSUInteger oldSection4 = [dataWithFixedOnly adjustedNumberOfItems:4 inSection:3];

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:1 inSection:0] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1] should equal(oldSection2);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:2] should equal(oldSection3);
                [dataWithFixedOnly adjustedNumberOfItems:4 inSection:3] should equal(oldSection4);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);
            });
        });

        context(@"when moving a middle section to a different middle section", ^{
            beforeEach(^{
                fromSection = 1;
                toSection = 2;
            });

            it(@"should have moved fromSection's ad positioning to toSection's ad positioning", ^{
                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,2)] should equal(_IP(0, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,2)] should equal(_IP(2, 2));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4,2)] should equal(_IP(0, 3));
            });

            it(@"should make it such that toSection's adjusted count is now what fromSection's was prior to the move", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, fromSection)];
                NSUInteger fromSectionCount = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:fromSection];

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:toSection] should equal(fromSectionCount);
            });

            it(@"should have shifted the ad positions of the other sections (not involved in the move) correctly", ^{
                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,0)] should equal(_IP(0, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,0)] should equal(_IP(3, 0));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(4,0)] should equal(_IP(0, 1));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,1)] should equal(_IP(0, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,1)] should equal(_IP(1, 1));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(3,1)] should equal(_IP(0, 2));

                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(0,3)] should equal(_IP(0, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(1,3)] should equal(_IP(1, 3));
                [dataWithFixedOnly nextAdInsertionIndexPathForAdjustedIndexPath:_IP(2,3)] should be_nil;
            });

            it(@"should have shifted the adjusted counts of the other sections (not involved in the move) correctly", ^{
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 0)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 2)];
                [dataWithFixedOnly insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(0, 3)];

                // The count at section 1 should match the count at section 0 after deletion.
                NSUInteger oldSection1 = [dataWithFixedOnly adjustedNumberOfItems:1 inSection:0];
                NSUInteger oldSection2 = [dataWithFixedOnly adjustedNumberOfItems:2 inSection:2];
                NSUInteger oldSection3 = [dataWithFixedOnly adjustedNumberOfItems:3 inSection:3];

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:1 inSection:0] should equal(oldSection1);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:1] should equal(oldSection2);
                [dataWithFixedOnly adjustedNumberOfItems:3 inSection:3] should equal(oldSection3);
            });

            it(@"should not have altered any section counts that should have never had data throughout the whole transaction", ^{
                // A weak test as we're only testing one section.
                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);

                [dataWithFixedOnly moveSection:fromSection toSection:toSection];

                [dataWithFixedOnly adjustedNumberOfItems:0 inSection:4] should equal(0);
                [dataWithFixedOnly adjustedNumberOfItems:2 inSection:4] should equal(2);
            });
        });
    });

    xdescribe(@"-adjustedIndexPathsWithAdsInSection:", {

    });
});

SPEC_END
