//
//  MoPub.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MoPub.h"
#import "MPConstants.h"
#import "MPCoreInstanceProvider.h"
#import "MPGeolocationProvider.h"
#import "MPRewardedVideo.h"

#import "FABKitProtocol.h"

@interface MoPub () <FABKit>

@property (nonatomic, strong) NSArray *globalMediationSettings;

@end

@implementation MoPub

+ (MoPub *)sharedInstance
{
    static MoPub *sharedInstance = nil;
    static dispatch_once_t initOnceToken;
    dispatch_once(&initOnceToken, ^{
        sharedInstance = [[MoPub alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)bundleIdentifier
{
    return MP_BUNDLE_IDENTIFIER;
}

+ (NSString *)kitDisplayVersion
{
    return MP_SDK_VERSION;
}

- (void)setLocationUpdatesEnabled:(BOOL)locationUpdatesEnabled
{
    _locationUpdatesEnabled = locationUpdatesEnabled;
    [[[MPCoreInstanceProvider sharedProvider] sharedMPGeolocationProvider] setLocationUpdatesEnabled:locationUpdatesEnabled];
}

- (void)start
{

}

// Keep -version and -bundleIdentifier methods around for Fabric backwards compatibility.
- (NSString *)version
{
    return MP_SDK_VERSION;
}

- (NSString *)bundleIdentifier
{
    return MP_BUNDLE_IDENTIFIER;
}

- (void)initializeRewardedVideoWithGlobalMediationSettings:(NSArray *)globalMediationSettings delegate:(id<MPRewardedVideoDelegate>)delegate
{
    // initializeWithDelegate: is a known private initialization method on MPRewardedVideo. So we forward the initialization call to that class.
    [MPRewardedVideo performSelector:@selector(initializeWithDelegate:) withObject:delegate];
    self.globalMediationSettings = globalMediationSettings;
}

- (id<MPMediationSettingsProtocol>)globalMediationSettingsForClass:(Class)aClass
{
    NSArray *mediationSettingsCollection = self.globalMediationSettings;

    for (id<MPMediationSettingsProtocol> settings in mediationSettingsCollection) {
        if ([settings isKindOfClass:aClass]) {
            return settings;
        }
    }

    return nil;
}

@end
