#import "MPVASTStringUtilities.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPVASTStringUtilitiesSpec)

describe(@"MPVASTStringUtilities", ^{
    describe(@"+timeIntervalFromString:", ^{
        it(@"should handle strings with HH:mm:ss.mmm format", ^{
            [MPVASTStringUtilities timeIntervalFromString:@"02:45:30.150"] should equal(9930.150);
            [MPVASTStringUtilities timeIntervalFromString:@"00:12:34.567"] should equal(754.567);
            [MPVASTStringUtilities timeIntervalFromString:@"00:12:34.56"] should equal(754.56);
            [MPVASTStringUtilities timeIntervalFromString:@"00:12:34.5"] should equal(754.5);
            [MPVASTStringUtilities timeIntervalFromString:@"00:00:01.000"] should equal(1);
            [MPVASTStringUtilities timeIntervalFromString:@"00:00:00.000"] should equal(0);
        });

        it(@"should handle strings with HH:mm:ss format", ^{
            [MPVASTStringUtilities timeIntervalFromString:@"02:45:30"] should equal(9930);
            [MPVASTStringUtilities timeIntervalFromString:@"00:12:34"] should equal(754);
            [MPVASTStringUtilities timeIntervalFromString:@"00:00:01"] should equal(1);
            [MPVASTStringUtilities timeIntervalFromString:@"00:00:00"] should equal(0);
        });

        it(@"should handle strings containing positive floating-point numbers", ^{
            [MPVASTStringUtilities timeIntervalFromString:@"30.150"] should equal(30.150);
            [MPVASTStringUtilities timeIntervalFromString:@"120.333"] should equal(120.333);
            [MPVASTStringUtilities timeIntervalFromString:@"34.56"] should equal(34.56);
            [MPVASTStringUtilities timeIntervalFromString:@"34.5"] should equal(34.5);
            [MPVASTStringUtilities timeIntervalFromString:@"09.000"] should equal(9);
            [MPVASTStringUtilities timeIntervalFromString:@"7.000"] should equal(7);
            [MPVASTStringUtilities timeIntervalFromString:@"0.000"] should equal(0);
        });

        it(@"should handle strings containing positive integers", ^{
            [MPVASTStringUtilities timeIntervalFromString:@"30"] should equal(30);
            [MPVASTStringUtilities timeIntervalFromString:@"120"] should equal(120);
            [MPVASTStringUtilities timeIntervalFromString:@"09"] should equal(9);
            [MPVASTStringUtilities timeIntervalFromString:@"7"] should equal(7);
            [MPVASTStringUtilities timeIntervalFromString:@"00"] should equal(0);
            [MPVASTStringUtilities timeIntervalFromString:@"0"] should equal(0);
        });

        context(@"with invalid strings", ^{
            it(@"should return 0", ^{
                [MPVASTStringUtilities timeIntervalFromString:@"abc"] should equal(0);
                [MPVASTStringUtilities timeIntervalFromString:@"-01:02:03.456"] should equal(0);
                [MPVASTStringUtilities timeIntervalFromString:@"00:14.92"] should equal(0);
                [MPVASTStringUtilities timeIntervalFromString:@"00:84:12.50"] should equal(0);
                [MPVASTStringUtilities timeIntervalFromString:@"00:00:72.50"] should equal(0);
            });
        });
    });

    describe(@"+stringFromTimeInterval:", ^{
        it(@"should return padded duration strings of the format HH:mm:ss.mmm", ^{
            [MPVASTStringUtilities stringFromTimeInterval:0] should equal(@"00:00:00.000");
            [MPVASTStringUtilities stringFromTimeInterval:23] should equal(@"00:00:23.000");
            [MPVASTStringUtilities stringFromTimeInterval:9930.150] should equal(@"02:45:30.150");
        });

        it(@"should round to three decimal places", ^{
            [MPVASTStringUtilities stringFromTimeInterval:12345.6789] should equal(@"03:25:45.679");
        });

        it(@"should return a zero duration string if the time interval is negative", ^{
            [MPVASTStringUtilities stringFromTimeInterval:-10.5] should equal(@"00:00:00.000");
        });
    });

    describe(@"+stringRepresentsNonNegativePercentage:", ^{
        it(@"should return YES for percentages up to 100%", ^{
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"0%"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"0.00%"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"3.1415%"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"56.5%"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"100%"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"100.0%"] should equal(YES);
        });

        it(@"should return NO for percentages greater than 100%", ^{
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"100.001%"] should equal(NO);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"155%"] should equal(NO);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"20000%"] should equal(NO);
        });

        it(@"should return NO for negative percentages", ^{
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"-1%"] should equal(NO);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"-15.2%"] should equal(NO);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"-100%"] should equal(NO);
        });

        it(@"should return NO for invalid percentage strings", ^{
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@""] should equal(NO);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"0"] should equal(NO);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"12"] should equal(NO);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"100"] should equal(NO);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"%"] should equal(NO);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"10%1%"] should equal(NO);
            [MPVASTStringUtilities stringRepresentsNonNegativePercentage:@"ab%"] should equal(NO);
        });
    });

    describe(@"+stringRepresentsNonNegativeDuration:", ^{
        it(@"should return YES for valid HH:mm:ss.mmm strings", ^{
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"02:45:30.150"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00:12:34.567"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00:12:34.56"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00:12:34.5"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00:00:01.000"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00:00:00.000"] should equal(YES);
        });

        it(@"should return YES for valid HH:mm:ss strings", ^{
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"02:45:30"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00:12:34"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00:00:01"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00:00:00"] should equal(YES);
        });

        it(@"should handle strings containing positive floating-point numbers", ^{
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"30.150"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"120.333"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"34.56"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"34.5"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"09.000"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"7.000"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"0.000"] should equal(YES);
        });

        it(@"should handle strings containing positive integers", ^{
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"30"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"120"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"09"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"7"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00"] should equal(YES);
            [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"0"] should equal(YES);
        });

        context(@"with invalid strings", ^{
            it(@"should return NO", ^{
                [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"abc"] should equal(NO);
                [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"-01:02:03.456"] should equal(NO);
                [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00:14.92"] should equal(NO);
                [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00:84:12.50"] should equal(NO);
                [MPVASTStringUtilities stringRepresentsNonNegativeDuration:@"00:00:72.50"] should equal(NO);
            });
        });
    });
});

SPEC_END
