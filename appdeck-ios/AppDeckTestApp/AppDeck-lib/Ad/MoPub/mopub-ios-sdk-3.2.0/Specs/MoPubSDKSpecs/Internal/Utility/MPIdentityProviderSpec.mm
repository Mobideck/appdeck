#import "MPIdentityProvider.h"
#import <AdSupport/AdSupport.h>
#import "ASIdentifierManager+MPSpecs.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

static BOOL ASIdentifierManagerExists;

@interface MPIdentityProvider (Spec)

+ (void)setASIdentifierManagerExists:(BOOL)exists;

@end

@implementation MPIdentityProvider (Spec)

+ (void)beforeEach
{
    ASIdentifierManagerExists = NO;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.mopub.identifier"];
}

+ (void)setASIdentifierManagerExists:(BOOL)exists
{
    ASIdentifierManagerExists = exists;
}

+ (BOOL)deviceHasASIdentifierManager
{
    return ASIdentifierManagerExists;
}

@end

SPEC_BEGIN(MPIdentityProviderSpec)

describe(@"MPIdentityProvider", ^{
    context(@"when ASIdentifierManager exists (iOS 6+)", ^{
        beforeEach(^{
            [MPIdentityProvider setASIdentifierManagerExists:YES];
        });

        context(@"when advertisingIdentifier is not nil", ^{
            beforeEach(^{
                [ASIdentifierManager useNilForAdvertisingIdentifier:NO];
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
                [ASIdentifierManager useNilForAdvertisingIdentifier:YES];
            });

            it(@"should provide an identifier that is ifa:(null)", ^{
                [MPIdentityProvider identifier] should equal(@"ifa:(null)");
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


    });

    context(@"when ASIdentifierManager does not exist", ^{
        beforeEach(^{
            [MPIdentityProvider setASIdentifierManagerExists:NO];
        });

        context(@"when the standard user defaults does not have an identifier", ^{
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
        });

        it(@"should return YES for advertisingTrackingEnabled", ^{
            [MPIdentityProvider advertisingTrackingEnabled] should equal(YES);
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
});

SPEC_END
