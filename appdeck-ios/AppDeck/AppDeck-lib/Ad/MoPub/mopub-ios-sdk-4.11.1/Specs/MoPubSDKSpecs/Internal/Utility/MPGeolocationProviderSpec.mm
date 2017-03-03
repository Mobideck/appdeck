#import "MPGeolocationProvider.h"

#import <CoreLocation/CoreLocation.h>
#import "CLLocationManager+MPSpecs.h"
#import "FakeCLLocationManager.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

extern NSTimeInterval kMPLocationUpdateDuration;
extern NSTimeInterval kMPLocationUpdateInterval;

static const NSTimeInterval kLeewayInterval = 1.0;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPGeolocationProvider (Spec) <CLLocationManagerDelegate>

@property (nonatomic) NSDate *timeOfLastLocationUpdate;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

SPEC_BEGIN(MPGeolocationProviderSpec)

describe(@"MPGeolocationProvider", ^{
    __block CLLocation *validLocation;
    __block FakeCLLocationManager *fakeLocationManager;
    __block MPGeolocationProvider *provider;

    beforeEach(^{
        validLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:30 verticalAccuracy:30 timestamp:[NSDate date]];
        fakeLocationManager = [[FakeCLLocationManager alloc] init];
        fakeCoreProvider.fakeLocationManager = fakeLocationManager;
    });

    describe(@"initialization", ^{
        subjectAction(^{ provider = [[MPGeolocationProvider alloc] init]; });

        context(@"when the location manager has an existing location at launch time", ^{
            context(@"if the location is valid", ^{
                beforeEach(^{
                    [fakeLocationManager setLocation:validLocation];
                });

                it(@"should set that location as its lastKnownLocation", ^{
                    provider.lastKnownLocation should equal(validLocation);
                });
            });

            context(@"if the location is invalid", ^{
                beforeEach(^{
                    // Bad horizontal accuracy.
                    CLLocation *invalidLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:-30 verticalAccuracy:30 timestamp:[NSDate date]];
                    [fakeLocationManager setLocation:invalidLocation];
                });

                it(@"should not set lastKnownLocation", ^{
                    provider.lastKnownLocation should be_nil;
                });
            });
        });

        context(@"when location services are disabled", ^{
            beforeEach(^{
                [CLLocationManager setLocationServicesEnabled:NO];
            });

            afterEach(^{
                [CLLocationManager setLocationServicesEnabled:YES];
            });

            context(@"when the app is not authorized to use location", ^{
                beforeEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusDenied];
                });

                afterEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusAuthorized];
                });

                it(@"should not start listening for location updates", ^{
                    fakeLocationManager.isUpdatingLocation should be_falsy;
                });
            });

            context(@"when the app is authorized to use location", ^{
                beforeEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusAuthorized];
                });

                it(@"should not start listening for location updates", ^{
                    fakeLocationManager.isUpdatingLocation should be_falsy;
                });
            });
        });

        context(@"when location services are enabled", ^{
            beforeEach(^{
                [CLLocationManager setLocationServicesEnabled:YES];
            });

            context(@"when the app is not authorized to use location", ^{
                beforeEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusDenied];
                });

                afterEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusAuthorized];
                });

                it(@"should not start listening for location updates", ^{
                    fakeLocationManager.isUpdatingLocation should be_falsy;
                });
            });

            context(@"when the app is authorized to use location", ^{
                beforeEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusAuthorized];
                });

                it(@"should start listening for location updates", ^{
                    fakeLocationManager.isUpdatingLocation should be_truthy;
                });
            });
        });
    });

    describe(@"locationUpdatesEnabled", ^{
        __block CLLocation *lastKnownLocation;

        beforeEach(^{
            // Mock out a location so the provider is initialized with a lastKnownLocation.
            lastKnownLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:30 verticalAccuracy:30 timestamp:[NSDate date]];
            [fakeLocationManager setLocation:lastKnownLocation];

            provider = [[MPGeolocationProvider alloc] init];
        });

        context(@"when set to YES", ^{
            subjectAction(^{
                provider.locationUpdatesEnabled = YES;
            });

            context(@"when neither currently updating nor scheduled to update", ^{
                beforeEach(^{
                    // Force the provider to stop all updates by injecting an "access denied" error.
                    [provider locationManager:fakeLocationManager didFailWithError:[NSError errorWithDomain:@"any" code:kCLErrorDenied userInfo:nil]];
                    fakeLocationManager.isUpdatingLocation should be_falsy;

                    provider.locationUpdatesEnabled = YES;
                });

                it(@"should start updating immediately", ^{
                    fakeLocationManager.isUpdatingLocation should be_truthy;
                });
            });
        });

        context(@"when set to NO", ^{
            beforeEach(^{
                // Pre-conditions for our tests:
                // - make sure there is a lastKnownLocation
                // - make sure the location manager is currently updating location
                provider.lastKnownLocation should equal(lastKnownLocation);
                fakeLocationManager.isUpdatingLocation should be_truthy;

                provider.locationUpdatesEnabled = NO;
            });

            it(@"should stop listening for location updates", ^{
                fakeLocationManager.isUpdatingLocation should be_falsy;
            });

            it(@"should nil out the last known location", ^{
                provider.lastKnownLocation should be_nil;
            });

            it(@"should always return nil for -lastKnownLocation even if a location update comes in", ^{
                // It seems that there can be a race condition in which
                // -locationManager:didUpdateLocations: is still called after the location manager
                // is told to stop updating its location. In this case, we don't want the location
                // to be accessible, so -lastKnownLocation should return nil.
                [provider locationManager:fakeLocationManager didUpdateLocations:@[validLocation]];
                provider.lastKnownLocation should be_nil;
            });
        });
    });

    describe(@"periodic location updates", ^{
        beforeEach(^{
            provider = [[MPGeolocationProvider alloc] init];
        });

        it(@"should limit the time the location manager spends updating its location", ^{
            fakeLocationManager.isUpdatingLocation should be_truthy;

            // Expect updating to stop once the update duration has passed.
            [fakeCoreProvider advanceMPTimers:kMPLocationUpdateDuration + kLeewayInterval];
            fakeLocationManager.isUpdatingLocation should be_falsy;
        });

        context(@"after the update time limit has elapsed", ^{
            it(@"should update again after a certain interval", ^{
                [fakeCoreProvider advanceMPTimers:kMPLocationUpdateDuration + kMPLocationUpdateInterval + kLeewayInterval];

                fakeLocationManager.isUpdatingLocation should be_truthy;
            });
        });
    });

    describe(@"CLLocationManagerDelegate methods", ^{
        describe(@"-locationManager:didChangeAuthorizationStatus:", ^{
            __block CLLocation *lastKnownLocation;

            beforeEach(^{
                lastKnownLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:30 verticalAccuracy:30 timestamp:[NSDate date]];
                [fakeLocationManager setLocation:lastKnownLocation];
                provider = [[MPGeolocationProvider alloc] init];
            });

            context(@"if access is undetermined", ^{
                it(@"should nil out its lastKnownLocation and stop any location updates", ^{
                    fakeLocationManager.isUpdatingLocation should be_truthy;

                    [provider locationManager:fakeLocationManager didChangeAuthorizationStatus:kCLAuthorizationStatusNotDetermined];
                    provider.lastKnownLocation should be_nil;

                    fakeLocationManager.isUpdatingLocation should be_falsy;
                });
            });

            context(@"if access is denied", ^{
                it(@"should nil out its lastKnownLocation and stop any location updates", ^{
                    fakeLocationManager.isUpdatingLocation should be_truthy;

                    [provider locationManager:fakeLocationManager didChangeAuthorizationStatus:kCLAuthorizationStatusDenied];
                    provider.lastKnownLocation should be_nil;

                    fakeLocationManager.isUpdatingLocation should be_falsy;
                });
            });

            context(@"if access is restricted", ^{
                it(@"should nil out its lastKnownLocation and stop any location updates", ^{
                    fakeLocationManager.isUpdatingLocation should be_truthy;

                    [provider locationManager:fakeLocationManager didChangeAuthorizationStatus:kCLAuthorizationStatusRestricted];
                    provider.lastKnownLocation should be_nil;

                    fakeLocationManager.isUpdatingLocation should be_falsy;
                });
            });

            context(@"if access is authorized", ^{
                it(@"should kick-off location updates", ^{
                    // Set up the test as if we had stopped location updates, so that we can verify
                    // that location updates were restarted.
                    [fakeLocationManager stopUpdatingLocation];

                    [provider locationManager:fakeLocationManager didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorized];
                    fakeLocationManager.isUpdatingLocation should be_truthy;
                });
            });

            context(@"if access is authorized for foreground use", ^{
                it(@"should kick-off location updates", ^{
                    // Set up the test as if we had stopped location updates, so that we can verify
                    // that location updates were restarted.
                    [fakeLocationManager stopUpdatingLocation];

                    [provider locationManager:fakeLocationManager didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
                    fakeLocationManager.isUpdatingLocation should be_truthy;
                });
            });
        });

        describe(@"-locationManager:didUpdateLocations:", ^{
            __block CLLocation *lastKnownLocation;
            __block NSDate *lastKnownLocationDate;

            beforeEach(^{
                lastKnownLocationDate = [NSDate date];
                lastKnownLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:30 verticalAccuracy:30 timestamp:lastKnownLocationDate];
                [fakeLocationManager setLocation:lastKnownLocation];
                provider = [[MPGeolocationProvider alloc] init];
            });

            context(@"if an incoming location is valid and newer than our lastKnownLocation", ^{
                it(@"should set lastKnownLocation", ^{
                    // Newer location with better horizontal accuracy than our lastKnownLocation.
                    CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:5 verticalAccuracy:30 timestamp:[NSDate dateWithTimeInterval:10 sinceDate:lastKnownLocationDate]];

                    [provider locationManager:fakeLocationManager didUpdateLocations:@[newLocation]];
                    provider.lastKnownLocation should equal(newLocation);
                });
            });

            context(@"if an incoming location has an invalid horizontal accuracy", ^{
                it(@"should not set lastKnownLocation", ^{
                    CLLocation *badLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:-10 verticalAccuracy:30 timestamp:[NSDate dateWithTimeInterval:10 sinceDate:lastKnownLocationDate]];

                    [provider locationManager:fakeLocationManager didUpdateLocations:@[badLocation]];
                    provider.lastKnownLocation should equal(lastKnownLocation);
                });
            });

            context(@"if an incoming location is older than our lastKnownLocation", ^{
                it(@"should not set lastKnownLocation", ^{
                    CLLocation *olderLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:30 verticalAccuracy:30 timestamp:[NSDate dateWithTimeInterval:-10 sinceDate:lastKnownLocationDate]];

                    [provider locationManager:fakeLocationManager didUpdateLocations:@[olderLocation]];
                    provider.lastKnownLocation should equal(lastKnownLocation);
                });
            });
        });

        describe(@"-locationManager:didFailWithError:", ^{
            beforeEach(^{
                provider = [[MPGeolocationProvider alloc] init];
            });

            context(@"with an 'access denied' error", ^{
                it(@"should stop listening for location updates", ^{
                    fakeLocationManager.isUpdatingLocation should be_truthy;

                    [provider locationManager:fakeLocationManager didFailWithError:[NSError errorWithDomain:@"any" code:kCLErrorDenied userInfo:nil]];
                    fakeLocationManager.isUpdatingLocation should be_falsy;
                });
            });
        });

        // iOS < 6.0
        describe(@"-locationManager:didUpdateToLocation:fromLocation:", ^{
            __block CLLocation *lastKnownLocation;
            __block NSDate *lastKnownLocationDate;

            beforeEach(^{
                lastKnownLocationDate = [NSDate date];
                lastKnownLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:30 verticalAccuracy:30 timestamp:lastKnownLocationDate];
                [fakeLocationManager setLocation:lastKnownLocation];
                provider = [[MPGeolocationProvider alloc] init];
            });

            context(@"if the new location is valid and newer than our lastKnownLocation", ^{
                it(@"should set lastKnownLocation", ^{
                    // Newer location with better horizontal accuracy than our lastKnownLocation.
                    CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:5 verticalAccuracy:30 timestamp:[NSDate dateWithTimeInterval:10 sinceDate:lastKnownLocationDate]];
                    [provider locationManager:fakeLocationManager didUpdateToLocation:newLocation fromLocation:nil];
                    provider.lastKnownLocation should equal(newLocation);
                });
            });

            context(@"if the new location is nil", ^{
                it(@"should not set lastKnownLocation", ^{
                    [provider locationManager:fakeLocationManager didUpdateToLocation:nil fromLocation:nil];
                    provider.lastKnownLocation should equal(lastKnownLocation);
                });
            });

            context(@"if the new location has an invalid horizontal accuracy", ^{
                it(@"should not set lastKnownLocation", ^{
                    CLLocation *badLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:-10 verticalAccuracy:30 timestamp:[NSDate dateWithTimeInterval:10 sinceDate:lastKnownLocationDate]];

                    [provider locationManager:fakeLocationManager didUpdateToLocation:badLocation fromLocation:nil];
                    provider.lastKnownLocation should equal(lastKnownLocation);
                });
            });

            context(@"if the new location is older than our lastKnownLocation", ^{
                it(@"should not set lastKnownLocation", ^{
                    CLLocation *olderLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37, -122) altitude:0 horizontalAccuracy:30 verticalAccuracy:30 timestamp:[NSDate dateWithTimeInterval:-10 sinceDate:lastKnownLocationDate]];

                    [provider locationManager:fakeLocationManager didUpdateToLocation:olderLocation fromLocation:nil];
                    provider.lastKnownLocation should equal(lastKnownLocation);
                });
            });
        });
    });

    describe(@"on application state changes", ^{
        beforeEach(^{
            provider = [[MPGeolocationProvider alloc] init];
        });

        context(@"when moving to the background", ^{
            it(@"should stop any current or scheduled location updates", ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

                fakeLocationManager.isUpdatingLocation should be_falsy;

                [fakeCoreProvider advanceMPTimers:kMPLocationUpdateDuration + kMPLocationUpdateInterval + kLeewayInterval];
                fakeLocationManager.isUpdatingLocation should be_falsy;
            });
        });

        context(@"when returning to the foreground", ^{
            context(@"if the last update was too long ago", ^{
                it(@"should immediately update", ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

                    provider.timeOfLastLocationUpdate = [NSDate dateWithTimeIntervalSinceNow:-(kMPLocationUpdateInterval + kLeewayInterval)];

                    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];

                    fakeLocationManager.isUpdatingLocation should be_truthy;
                });
            });

            context(@"if the last update is not yet considered stale", ^{
                xit(@"should wait for the staleness threshold to be reached before updating", ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

                    provider.timeOfLastLocationUpdate = [NSDate dateWithTimeIntervalSinceNow:-(kMPLocationUpdateInterval / 2)];

                    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];

                    fakeLocationManager.isUpdatingLocation should be_falsy;

                    [fakeCoreProvider advanceMPTimers:kMPLocationUpdateInterval / 2 + kLeewayInterval];

                    fakeLocationManager.isUpdatingLocation should be_truthy;
                });
            });
        });
    });
});

SPEC_END

#pragma clang diagnostic pop
