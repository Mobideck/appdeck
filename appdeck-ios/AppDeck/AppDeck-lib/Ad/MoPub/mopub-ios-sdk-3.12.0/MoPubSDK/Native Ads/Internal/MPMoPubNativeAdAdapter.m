//
//  MPMoPubNativeAdAdapter.m
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPMoPubNativeAdAdapter.h"
#import "MPNativeAdError.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPCoreInstanceProvider.h"

#define kImpressionTrackerURLsKey   @"imptracker"
#define kDefaultActionURLKey        @"clk"
#define kClickTrackerURLKey         @"clktracker"

static NSString *kDAAIconImageName = @"MPDAAIcon";
static NSString *kDAAIconTapDestinationURL = @"https://www.mopub.com/optout";

@interface MPMoPubNativeAdAdapter () <MPAdDestinationDisplayAgentDelegate>

@property (nonatomic, readonly, strong) MPAdDestinationDisplayAgent *destinationDisplayAgent;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, copy) void (^actionCompletionBlock)(BOOL, NSError *);

@end

@implementation MPMoPubNativeAdAdapter

@synthesize properties = _properties;
@synthesize defaultActionURL = _defaultActionURL;

- (instancetype)initWithAdProperties:(NSMutableDictionary *)properties
{
    if (self = [super init]) {
        BOOL valid = YES;

        NSArray *impressionTrackers = [properties objectForKey:kImpressionTrackerURLsKey];
        if (![impressionTrackers isKindOfClass:[NSArray class]] || [impressionTrackers count] < 1) {
            valid = NO;
        } else {
            _impressionTrackers = impressionTrackers;
        }

        NSString *engagementTracker = [properties objectForKey:kClickTrackerURLKey];
        if (engagementTracker == nil) {
            valid = NO;
        } else {
            _engagementTrackingURL = [NSURL URLWithString:engagementTracker];
        }

        _defaultActionURL = [NSURL URLWithString:[properties objectForKey:kDefaultActionURLKey]];

        [properties removeObjectsForKeys:[NSArray arrayWithObjects:kImpressionTrackerURLsKey, kClickTrackerURLKey, kDefaultActionURLKey, nil]];
        _properties = properties;

        if (!valid) {
            return nil;
        }

        _destinationDisplayAgent = [[MPCoreInstanceProvider sharedProvider] buildMPAdDestinationDisplayAgentWithDelegate:self];
    }

    return self;
}

- (void)dealloc
{
    [_destinationDisplayAgent cancel];
    [_destinationDisplayAgent setDelegate:nil];
}

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller
                  completion:(void (^)(BOOL success, NSError *error))completionBlock
{
    NSError *error = nil;

    if (!controller) {
        error = MPNativeAdNSErrorForContentDisplayErrorMissingRootController();
    }

    if (!URL || ![URL isKindOfClass:[NSURL class]] || ![URL.absoluteString length]) {
        error = MPNativeAdNSErrorForContentDisplayErrorInvalidURL();
    }

    if (error) {

        if (completionBlock) {
            completionBlock(NO, error);
        }

        return;
    }

    self.actionCompletionBlock = completionBlock;

    [self.destinationDisplayAgent displayDestinationForURL:URL];
}

#pragma mark - DAA Icon

- (void)daaIconTapped
{
    [self.destinationDisplayAgent displayDestinationForURL:[NSURL URLWithString:kDAAIconTapDestinationURL]];
}

- (void)loadDAAIconIntoImageView:(UIImageView *)imageView
{
    imageView.image = [UIImage imageNamed:MPResourcePathForResource(kDAAIconImageName)];

    // Attach a gesture recognizer to handle loading the daa icon URL.
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(daaIconTapped)];
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:tapRecognizer];
}

#pragma mark - <MPAdDestinationDisplayAgent>

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)displayAgentWillPresentModal
{

}

- (void)displayAgentWillLeaveApplication
{
    if (self.actionCompletionBlock) {
        self.actionCompletionBlock(YES, nil);
        self.actionCompletionBlock = nil;
    }

}

- (void)displayAgentDidDismissModal
{
    if (self.actionCompletionBlock) {
        self.actionCompletionBlock(YES, nil);
        self.actionCompletionBlock = nil;
    }

    self.rootViewController = nil;
}
@end
