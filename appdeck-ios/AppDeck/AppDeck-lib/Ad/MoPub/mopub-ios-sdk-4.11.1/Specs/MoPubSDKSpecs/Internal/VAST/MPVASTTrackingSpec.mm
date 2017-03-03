#import "CedarAsync.h"

#import "FakeMPAnalyticsTracker.h"
#import "FakeMPCoreInstanceProvider.h"
#import "MOPUBNativeVideoImpressionAgent.h"
#import "MPVASTManager.h"
#import "MPVASTTracking.h"
#import "MPVideoConfig.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPVASTTracking (Specs)

@property (nonatomic) MOPUBNativeVideoImpressionAgent *customViewabilityTrackingAgent;

@end

@interface MOPUBNativeVideoImpressionAgent (Specs)

@property (nonatomic, weak) UIView *measuredVideoView;

@end

SPEC_BEGIN(MPVideoTrackerSpec)

describe(@"MPVideoTracker", ^{
    __block MPVASTTracking *tracker;
    __block void (^completion)(MPVASTResponse *, NSError *);
    __block NSData *VASTData;
    __block MPVideoConfig *videoConfig;
    __block MPVASTResponse *VASTResponse;
    __block FakeMPAnalyticsTracker *sharedFakeMPAnalyticsTracker;

    beforeEach(^{
        completion = [^(MPVASTResponse *resp, NSError *err) {
            VASTResponse = resp;
        } copy];

        VASTData = nil;
        VASTResponse = nil;
        sharedFakeMPAnalyticsTracker = [[FakeMPCoreInstanceProvider sharedProvider] sharedFakeMPAnalyticsTracker];
        [sharedFakeMPAnalyticsTracker reset];
    });

    subjectAction(^{
        [MPVASTManager fetchVASTWithData:VASTData completion:completion];

        // Since the VAST manager executes asynchronously, we want to wait until the results
        // come back before proceeding with any test.
        in_time(VASTResponse) should_not be_nil;

        videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:VASTResponse];
        tracker = [[MPVASTTracking alloc] initWithMPVideoConfig:videoConfig videoView:nil];
        tracker.videoDuration = 30;
    });

    context(@"updating the player view", ^{
        beforeEach(^{
            VASTData = dataFromXMLFileNamed(@"linear-tracking");
        });

        it(@"should create a new custom viewability tracking agent with the new view", ^{
            UIView *newView = [[UIView alloc] init];
            [tracker handleNewVideoView:newView];
            tracker.customViewabilityTrackingAgent.measuredVideoView should equal(newView);
        });
    });

    context(@"when handling a time update for standard progress trackers", ^{
        beforeEach(^{
            VASTData = dataFromXMLFileNamed(@"linear-tracking");
        });

        it(@"should fire start tracker immediately", ^{
            [videoConfig.startTrackers count] should equal(1);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/start"]]);
        });

        it(@"should fire first quartile tracker after 25% progress", ^{
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:.5];
            [videoConfig.firstQuartileTrackers count] should equal(1);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/start"]]);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:8];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs[1] should equal([[NSURL alloc] initWithString:@"http://myTrackingURL/firstQuartile"]);
        });

        it(@"should fire midpoint tracker after 50% progress", ^{
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:.5];
            [videoConfig.midpointTrackers count] should equal(1);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/start"]]);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:15];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs[1] should equal([[NSURL alloc] initWithString:@"http://myTrackingURL/midpoint"]);
        });

        it(@"should fire third quartile tracker after 75% progress", ^{
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:.5];
            [videoConfig.thirdQuartileTrackers count] should equal(1);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/start"]]);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:23];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs[1] should equal([[NSURL alloc] initWithString:@"http://myTrackingURL/thirdQuartile"]);
        });
    });

    context(@"when handling a time update for other progress trackers", ^{
        beforeEach(^{
            VASTData = dataFromXMLFileNamed(@"linear-progress-tracking");
        });

        it(@"when a second has passed, no trackers should be fired", ^{
            [videoConfig.otherProgressTrackers count] should equal(4);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:1];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
        });

        it(@"should fire first tracker after 10% progress", ^{
            [videoConfig.otherProgressTrackers count] should equal(4);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:3];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/progress_percentage_offset1"]]);
        });

        it(@"should fire second tracker after 11 seconds progress", ^{
            [videoConfig.otherProgressTrackers count] should equal(4);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:11];
            [sharedFakeMPAnalyticsTracker.trackingRequestURLs count] should equal(2);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should contain([[NSURL alloc] initWithString:@"http://myTrackingURL/progress_percentage_offset1"]);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should contain([[NSURL alloc] initWithString:@"http://myTrackingURL/progress_absolute_offset1"]);
        });

        it(@"should fire third tracker after 22 seconds progress", ^{
            [videoConfig.otherProgressTrackers count] should equal(4);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:22];
            [sharedFakeMPAnalyticsTracker.trackingRequestURLs count] should equal(3);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should contain([[NSURL alloc] initWithString:@"http://myTrackingURL/progress_percentage_offset1"]);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should contain([[NSURL alloc] initWithString:@"http://myTrackingURL/progress_absolute_offset2"]);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should contain([[NSURL alloc] initWithString:@"http://myTrackingURL/progress_absolute_offset1"]);
        });

        it(@"should fire third tracker after 90% seconds progress", ^{
            [videoConfig.otherProgressTrackers count] should equal(4);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:27];
            [sharedFakeMPAnalyticsTracker.trackingRequestURLs count] should equal(4);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should contain([[NSURL alloc] initWithString:@"http://myTrackingURL/progress_percentage_offset1"]);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should contain([[NSURL alloc] initWithString:@"http://myTrackingURL/progress_absolute_offset2"]);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should contain([[NSURL alloc] initWithString:@"http://myTrackingURL/progress_absolute_offset1"]);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should contain([[NSURL alloc] initWithString:@"http://myTrackingURL/progress_percentage_offset2"]);
        });
    });

    context(@"when handling non time update events", ^{
        beforeEach(^{
            VASTData = dataFromXMLFileNamed(@"linear-event-tracking");
        });

        it(@"event should not fire if start tracker has not fired yet", ^{
            [videoConfig.muteTrackers count] should equal(1);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeMuted videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
        });

        it(@"mute tracker should fire for a mute event", ^{
            [videoConfig.muteTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeMuted videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/mute"]]);
        });

        it(@"impression tracker should fire for an impression event", ^{
            [videoConfig.impressionURLs count] should equal(2);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeImpression videoTimeOffset:2];
            [sharedFakeMPAnalyticsTracker.trackingRequestURLs count] should equal(2);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should contain([[NSURL alloc] initWithString:@"http://myTrackingURL/impression"]);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should contain([[NSURL alloc] initWithString:@"http://myTrackingURL/impression2"]);
        });

        it(@"impression tracker should not fire a second time for a second impression event", ^{
            [videoConfig.impressionURLs count] should equal(2);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeImpression videoTimeOffset:2];
             [sharedFakeMPAnalyticsTracker.trackingRequestURLs count] should equal(2);
            [tracker handleVideoEvent:MPVideoEventTypeImpression videoTimeOffset:2];
             [sharedFakeMPAnalyticsTracker.trackingRequestURLs count] should equal(2);
        });

        it(@"unmute tracker should fire for an unmute event", ^{
            [videoConfig.unmuteTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeUnmuted videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/unmute"]]);
        });

        it(@"click tracker should fire for a click event", ^{
            [videoConfig.unmuteTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeClick videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/click"]]);
        });

        it(@"pause tracker should fire for a pause event", ^{
            [videoConfig.pauseTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypePause videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/pause"]]);
        });

        it(@"resume tracker should fire for a resume event", ^{
            [videoConfig.resumeTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeResume videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/resume"]]);
        });

        it(@"fullscreen tracker should fire for a fullscreen event", ^{
            [videoConfig.fullscreenTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeFullScreen videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/fullscreen"]]);
        });

        it(@"exitFullscreen tracker should fire for an exitFullscreen event", ^{
            [videoConfig.exitFullscreenTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeExitFullScreen videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/exitfullscreen"]]);
        });

        it(@"expand tracker should fire for an expand event", ^{
            [videoConfig.expandTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeExpand videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/expand"]]);
        });

        it(@"collapse tracker should fire for a collapse event", ^{
            [videoConfig.collapseTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeCollapse videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/collapse"]]);
        });

        it(@"complete tracker should fire for a complete event", ^{
            [videoConfig.completionTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeCompleted videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/complete"]]);
        });

        it(@"complete tracker should only fire once", ^{
            [videoConfig.completionTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeCompleted videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/complete"]]);
             [tracker handleVideoEvent:MPVideoEventTypeCompleted videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/complete"]]);
        });

        it(@"error tracker should fire for an error event even without start event", ^{
            [videoConfig.completionTrackers count] should equal(1);
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeError videoTimeOffset:0];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myErrorURL/error"]]);
        });

        it(@"complete tracker should only fire once", ^{
            [videoConfig.completionTrackers count] should equal(1);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:2];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeCompleted videoTimeOffset:0];
            [tracker handleVideoEvent:MPVideoEventTypeCompleted videoTimeOffset:1];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[[[NSURL alloc] initWithString:@"http://myTrackingURL/complete"]]);
        });

        it(@"firing a time update event will not fire any trackers", ^{
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
            [tracker handleVideoEvent:MPVideoEventTypeTimeUpdate videoTimeOffset:10];
            sharedFakeMPAnalyticsTracker.trackingRequestURLs should equal(@[]);
        });
    });
});

SPEC_END
