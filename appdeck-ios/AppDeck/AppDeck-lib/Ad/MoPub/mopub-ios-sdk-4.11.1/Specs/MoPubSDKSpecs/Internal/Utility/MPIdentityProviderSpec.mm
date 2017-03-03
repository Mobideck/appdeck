#import "MPIdentityProvider.h"
#import <AdSupport/AdSupport.h>
#import "ASIdentifierManager+MPSpecs.h"
#import "MoPub.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#define MOPUB_IDENTIFIER_LAST_SET_TIME_KEY @"com.mopub.identifiertime"
#define MOPUB_WEEK_IN_SECONDS   (7 * 24 * 60 * 60)
#define MOPUB_ALL_ZERO_IFA      @"ifa:00000000-0000-0000-0000-000000000000"

@interface MPIdentityProvider (Spec)

@end

@implementation MPIdentityProvider (Spec)

+ (void)beforeEach
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.mopub.identifier"];
}

@end

SPEC_BEGIN(MPIdentityProviderSpec)

describe(@"MPIdentityProvider", ^{
    context(@"when advertisingIdentifier is from ASIdentifierManager", ^{
        beforeEach(^{
            [ASIdentifierManager useAdvertisingIdentifierType:MPSpecAdvertisingIdentifierTypeOriginal];
        });

        it(@"should provide the identity provided by the ASIdentifierManager", ^{
            NSString *identifier = [NSString stringWithFormat:@"ifa:%@", [[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] uppercaseString]];
            [MPIdentityProvider identifier] should equal(identifier);
        });

        it(@"should return whatever the ASIdentifierManager returns for advertisingTrackingEnabled", ^{
            [MPIdentityProvider advertisingTrackingEnabled] should equal([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]);
        });

        context(@"when retrieving obfuscatedIdentifier", ^{
            __block NSString *identifier;
            __block NSString *obfuscatedIdentifier;

            beforeEach(^{
                identifier = [MPIdentityProvider identifier];
                obfuscatedIdentifier = [MPIdentityProvider obfuscatedIdentifier];
            });

            it(@"should equal ifa:XXXX", ^{
                obfuscatedIdentifier should equal(@"ifa:XXXX");
            });

            it(@"should not affect the non-obfuscated identifier", ^{
                identifier should_not equal(obfuscatedIdentifier);
                // We already retrieved in the following order: identifier, obfuscatedIdentifier.  So we get identifier again to make sure obfuscatedIdentifier
                // didn't screw up the real token.
                [MPIdentityProvider identifier] should equal(identifier);
            });
        });
    });

    context(@"when advertisingIdentifier is nil", ^{
        beforeEach(^{
            [ASIdentifierManager useAdvertisingIdentifierType:MPSpecAdvertisingIdentifierTypeNil];
        });

        it(@"should provide the identity provided by the ASIdentifierManager", ^{
            NSString *identifier = [NSString stringWithFormat:@"ifa:%@", [[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] uppercaseString]];
            [MPIdentityProvider identifier] should equal(identifier);
        });

        context(@"when retrieving obfuscatedIdentifier", ^{
            __block NSString *identifier;
            __block NSString *obfuscatedIdentifier;

            beforeEach(^{
                identifier = [MPIdentityProvider identifier];
                obfuscatedIdentifier = [MPIdentityProvider obfuscatedIdentifier];
            });

            it(@"should equal ifa:XXXX", ^{
                obfuscatedIdentifier should equal(@"ifa:XXXX");
            });

            it(@"should not affect the non-obfuscated identifier", ^{
                identifier should_not equal(obfuscatedIdentifier);
                // We already retrieved in the following order: identifier, obfuscatedIdentifier.  So we get identifier again to make sure obfuscatedIdentifier
                // didn't screw up the real token.
                [MPIdentityProvider identifier] should equal(identifier);
            });
        });
    });

    context(@"when advertising ids are all 0", ^{
        beforeEach(^{
            [ASIdentifierManager useAdvertisingIdentifierType:MPSpecAdvertisingIdentifierTypeAllZero];
            [MoPub sharedInstance].frequencyCappingIdUsageEnabled = YES;
        });

        context(@"when frequencyCappingIdUsageEnabled is set to YES", ^{
            __block NSString *identifier;

            beforeEach(^{
                identifier = [MPIdentityProvider identifier];
            });

            it(@"should generate an identifier and store it", ^{
                identifier.length should be_greater_than(20); // "mopub:" + a reasonable amount of chars
                [identifier hasPrefix:@"mopub:"] should equal(YES);

                [[NSUserDefaults standardUserDefaults] objectForKey:@"com.mopub.identifier"] should equal(identifier);
            });

            context(@"when asked for the identifier again", ^{
                it(@"should return the same identifier", ^{
                    [MPIdentityProvider identifier] should equal(identifier);
                });
            });

            context(@"when the standard user defaults are cleared out", ^{
                it(@"should always return a different identifier", ^{
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.mopub.identifier"];
                    [MPIdentityProvider identifier] should_not equal(identifier);

                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.mopub.identifier"];
                    [MPIdentityProvider identifier] should_not equal(identifier);
                });
            });

            context(@"when the identifier is stored less or equal than 24 hours", ^ {
                it(@"should return the same identifier", ^{
                    NSString *oldIdentifier = [MPIdentityProvider identifier];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY];
                    NSString *newIdentifier = [MPIdentityProvider identifier];
                    oldIdentifier should equal(newIdentifier);
                });
            });

            context(@"when the identifier is stored more than 24 hours", ^ {
                it(@"should return different identifier", ^{
                    NSString *oldIdentifier = [MPIdentityProvider identifier];
                    [[NSUserDefaults standardUserDefaults] setObject:[[NSDate date] dateByAddingTimeInterval: -1 * MOPUB_WEEK_IN_SECONDS] forKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY];
                    NSString *newIdentifier = [MPIdentityProvider identifier];
                    newIdentifier should_not be_nil;
                    oldIdentifier should_not equal(newIdentifier);
                });

                it(@"should have an updated timestamp", ^{
                    NSString *oldTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY];
                    [[NSUserDefaults standardUserDefaults] setObject:[[NSDate date] dateByAddingTimeInterval: -1 * MOPUB_WEEK_IN_SECONDS] forKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY];
                    [MPIdentityProvider identifier];
                    NSString *newTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY];
                    newTimestamp should_not be_nil;
                    oldTimestamp should_not equal(newTimestamp);
                });
            });
        });

        context(@"when frequencyCappingIdUsageEnabled is set to NO", ^{
            beforeEach(^{
                [MoPub sharedInstance].frequencyCappingIdUsageEnabled = NO;
            });
            it(@"should return ifa:00000000-0000-0000-0000-000000000000", ^{
                [MPIdentityProvider identifier] should equal(MOPUB_ALL_ZERO_IFA);
            });
        });

        it(@"should return YES for advertisingTrackingEnabled", ^{
            [MPIdentityProvider advertisingTrackingEnabled] should equal(YES);
        });
    });

    context(@"when retrieving obfuscatedIdentifier", ^{
        __block NSString *identifier;
        __block NSString *obfuscatedIdentifier;

        beforeEach(^{
            identifier = [MPIdentityProvider identifier];
            obfuscatedIdentifier = [MPIdentityProvider obfuscatedIdentifier];
        });

        it(@"should equal mopub:XXXX", ^{
            obfuscatedIdentifier should equal(@"mopub:XXXX");
        });

        it(@"should not affect the non-obfuscated identifier", ^{
            identifier should_not equal(obfuscatedIdentifier);
            // We already retrieved in the following order: identifier, obfuscatedIdentifier.  So we get identifier again to make sure obfuscatedIdentifier
            // didn't screw up the real token.
            [MPIdentityProvider identifier] should equal(identifier);
        });
    });
});

SPEC_END
