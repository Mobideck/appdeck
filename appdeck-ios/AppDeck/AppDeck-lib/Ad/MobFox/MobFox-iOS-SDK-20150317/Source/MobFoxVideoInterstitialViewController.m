

#import "MobFoxVideoInterstitialViewController.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import "NSString+MobFox.h"
#import "DTXMLDocument.h"
#import "DTXMLElement.h"
#import "VASTXMLParser.h"

#import "NSURL+MobFox.h"
#import "MobFoxAdBrowserViewController.h"
#import "MobFoxToolBar.h"

#import "MobFoxBannerView.h"

#import "UIImage+MobFox.h"
#import "UIButton+MobFox.h"

#import <QuartzCore/QuartzCore.h>

#import "UIDevice+IdentifierAddition.h"

#include "MobFoxVideoPlayerViewController.h" 
#include "MobFoxInterstitialPlayerViewController.h"

#import <AdSupport/AdSupport.h>
#import "AdMobCustomEventFullscreen.h"
#import "iAdCustomEventFullscreen.h"
#import "CustomEvent.h"

NSString * const MobFoxVideoInterstitialErrorDomain = @"MobFoxVideoInterstitial";

@interface MobFoxVideoInterstitialViewController ()<UIGestureRecognizerDelegate, UIActionSheetDelegate, CustomEventFullscreenDelegate, MobFoxBannerViewDelegate> {
    BOOL videoSkipButtonShow;
    NSTimeInterval videoSkipButtonDisplayDelay;
    BOOL videoTimerShow;
    NSInteger videoDuration;
    BOOL videoSkipButtonDisplayed;
    BOOL videoHtmlOverlayDisplayed;
    NSTimeInterval videoHTMLOverlayDisplayDelay;
    BOOL videoVideoFailedToLoad;
    NSInteger videoCheckLoadedCount;
    BOOL videoWasSkipped;
    BOOL interstitialSkipButtonShow;
    BOOL interstitialLoadedFromURL;
    NSTimeInterval interstitialSkipButtonDisplayDelay;
    BOOL interstitialSkipButtonDisplayed;
    BOOL interstitialAutoCloseDisabled;
    NSTimeInterval interstitialAutoCloseDelay;
    BOOL interstitialTimerShow;
    BOOL readyToPlaySecondaryInterstitial;
    BOOL alreadyRequestedInterstitial;
    BOOL alreadyRequestedVideo;
    
    UIInterfaceOrientation requestedAdOrientation;
    
    BOOL currentlyPlayingInterstitial;
    float statusBarHeight;
    BOOL statusBarWasVisible;
    BOOL videoWasPlaying;
    BOOL videoWasPlayingBeforeResign;
    float buttonSize;
    float videoEndButtonWidth;
    float videoEndButtonHeight;
    MobFoxAdType advertTypeCurrentlyPlaying;
    BOOL advertRequestInProgress;
    NSTimeInterval stalledVideoStartTime;

    NSString *adVideoOrientation;
    NSString *adInterstitialOrientation;

    UIViewController *viewController;
    UIViewController *videoViewController;
    UIViewController *interstitialViewController;

    NSMutableArray *customEvents;

    NSInteger HTMLOverlayWidth;
    NSInteger HTMLOverlayHeight;

    UIView *tempView;
}

@property (nonatomic, strong) MobFoxVideoPlayerViewController *mobFoxVideoPlayerViewController;
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (nonatomic, strong) NSMutableArray *videoTopToolbarButtons;
@property (nonatomic, strong) MobFoxToolBar *videoTopToolbar;
@property (nonatomic, strong) NSMutableArray *vastAds;
@property (nonatomic, strong) MobFoxToolBar *videoBottomToolbar;
@property (nonatomic, strong) UIImage *videoPauseButtonImage;
@property (nonatomic, strong) UIImage *videoPlayButtonImage;
@property (nonatomic, strong) UIImage *videoPauseButtonDisabledImage;
@property (nonatomic, strong) UIImage *videoPlayButtonDisabledImage;
@property (nonatomic, strong) NSTimer *videoTimer;
@property (nonatomic, strong) UILabel *videoTimerLabel;
@property (nonatomic, strong) NSString *videoHTMLOverlayHTML;
@property (nonatomic, strong) UIWebView *videoHTMLOverlayWebView;
@property (nonatomic, strong) UIButton *videoSkipButton;
@property (nonatomic, strong) NSTimer *videoStalledTimer;

@property (nonatomic, strong) MobFoxInterstitialPlayerViewController *mobFoxInterstitialPlayerViewController;

@property (nonatomic, strong) CustomEventFullscreen *customEventFullscreen;

@property (nonatomic, strong) MobFoxToolBar *interstitialTopToolbar;
@property (nonatomic, strong) MobFoxToolBar *interstitialBottomToolbar;
@property (nonatomic, strong) NSMutableArray *interstitialTopToolbarButtons;
@property (nonatomic, strong) UIView *interstitialHoldingView;
@property (nonatomic, strong) UIWebView *interstitialWebView;
@property (nonatomic, strong) NSDate *timerStartTime;
@property (nonatomic, strong) NSTimer *interstitialTimer;
@property (nonatomic, strong) UILabel *interstitialTimerLabel;
@property (nonatomic, strong) NSString *interstitialMarkup;
@property (nonatomic, strong) UIButton *browserBackButton;
@property (nonatomic, strong) UIButton *browserForwardButton;
@property (nonatomic, strong) UIButton *videoReplayButton;
@property (nonatomic, strong) UIButton *videoClickButton;
@property (nonatomic, strong) NSString *interstitialURL;
@property (nonatomic, strong) NSString *videoClickThrough;
@property (nonatomic, strong) NSString *overlayClickThrough;

@property (nonatomic, strong) UIButton *interstitialSkipButton;

@property (nonatomic, strong) NSMutableArray *videoAdvertTrackingEvents;

@property (nonatomic, strong) NSString *IPAddress;

@property (nonatomic, assign) CGFloat currentLatitude;
@property (nonatomic, assign) CGFloat currentLongitude;

@property(nonatomic, readwrite, getter=isAdvertLoaded) BOOL advertLoaded;
@property(nonatomic, readwrite, getter=isAdvertViewActionInProgress) BOOL advertViewActionInProgress;

@property (nonatomic, strong) NSString *userAgent;

@property (nonatomic, strong) NSMutableDictionary *browserUserAgentDict;

- (BOOL)videoCreateAdvert:(DTXMLElement*)videoElement;
- (void)videoReplayButtonAction:(id)sender;
- (void)videoStartTimer;
- (void)videoStopTimer;
- (void)videoShowSkipButton;
- (void)videoShowHTMLOverlay;
- (void)videoPlayAdvert;
- (void)videoStalledStartTimer;
- (void)videoStalledStopTimer;
- (void)videoFailedToLoad;
- (void)checkVideoLoadedAndReadyToPlay;
- (void)videoTidyUpAfterAd;

- (void)interstitialStartTimer;
- (void)interstitialStopTimer;
- (void)interstitialSkipAction:(id)sender;

- (void)advertAddNotificationObservers:(MobFoxAdGroupType)adGroup;
- (void)advertRemoveNotificationObservers:(MobFoxAdGroupType)adGroup;
- (void)advertCreationFailed;
- (void)advertCreatedSuccessfully:(MobFoxAdType)advertType;
- (void)advertActionTrackingEvent:(NSString*)eventType;
- (void)advertShow:(MobFoxAdType)advertType viewToShow:(UIView*)viewToShow;
- (void)advertTidyUpAfterAd:(MobFoxAdType)advertType;

- (void)setup;
- (void)showStatusBarIfNecessary;
- (void)hideStatusBar;

- (void)updateAllFrames:(UIInterfaceOrientation)interfaceOrientation;
- (CGRect)returnVideoHTMLOverlayFrame;
- (CGRect)returnInterstitialWebFrame;
- (NSString*)returnDeviceIPAddress;

@end


@implementation MobFoxVideoInterstitialViewController

@synthesize delegate, locationAwareAdverts, enableInterstitialAds, prioritizeVideoAds, enableVideoAds, currentLatitude, currentLongitude, advertLoaded, advertViewActionInProgress, requestURL;

@synthesize videoAdvertTrackingEvents, IPAddress;
@synthesize mobFoxVideoPlayerViewController, videoPlayer, videoTopToolbar, videoBottomToolbar, videoTopToolbarButtons, videoSkipButton, videoStalledTimer; 
@synthesize videoPauseButtonDisabledImage, videoPlayButtonDisabledImage,videoPauseButtonImage, videoPlayButtonImage, videoTimer, videoTimerLabel, interstitialTimer;
@synthesize videoHTMLOverlayHTML, videoHTMLOverlayWebView;
@synthesize timerStartTime, interstitialTimerLabel;
@synthesize interstitialTopToolbar, interstitialBottomToolbar, interstitialTopToolbarButtons, interstitialSkipButton;
@synthesize interstitialURL, interstitialHoldingView, interstitialWebView, interstitialMarkup, browserBackButton, browserForwardButton, videoClickButton, videoReplayButton;
@synthesize userAgent;
@synthesize vastAds, video_max_duration, video_min_duration;
@synthesize userAge, userGender, keywords;


#pragma mark - Init/Dealloc Methods

- (UIColor *)randomColor
{
    CGFloat red = (arc4random()%256)/256.0;
    CGFloat green = (arc4random()%256)/256.0;
    CGFloat blue = (arc4random()%256)/256.0;

    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    enableInterstitialAds = YES;

    [self setUpBrowserUserAgentStrings];

    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        buttonSize = 40.0f;
        videoEndButtonHeight = 50;
        videoEndButtonWidth = 190;
    }
    else
    {
        buttonSize = 50.0f;
        videoEndButtonHeight = 60;
        videoEndButtonWidth = 220;
    }
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    } else {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
    }

    CGRect mainFrame = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:mainFrame];
    self.view.backgroundColor = [UIColor clearColor];

	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.wantsFullScreenLayout = YES;
    self.view.autoresizesSubviews = YES;
    customEvents = [[NSMutableArray alloc]init];

    self.view.alpha = 0.0f;
    self.view.hidden = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

    self.IPAddress = [self returnDeviceIPAddress];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.delegate = nil;
    [self videoStopTimer]; 
    [self interstitialStopTimer];

    self.videoHTMLOverlayWebView.delegate = nil;
}

#pragma mark - Utilities

- (void)setUpBrowserUserAgentStrings {

    NSArray *array;
    self.browserUserAgentDict = [NSMutableDictionary dictionaryWithCapacity:0];
	array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.2.2"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.2.1"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.2"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.9"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.8"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.7"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.6"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.5"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.4"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.3"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.2"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.1"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.0.2"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.0.1"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.0"];
    array = @[@" Version/5.1", @" Safari/7534.48.3"];
    [self.browserUserAgentDict setObject:array forKey:@"5.1.1"];
    array = @[@" Version/5.1", @" Safari/7534.48.3"];
    [self.browserUserAgentDict setObject:array forKey:@"5.1"];
    array = @[@" Version/5.1", @" Safari/7534.48.3"];
    [self.browserUserAgentDict setObject:array forKey:@"5.0.1"];
    array = @[@" Version/5.1", @" Safari/7534.48.3"];
    [self.browserUserAgentDict setObject:array forKey:@"5.0"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3.5"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3.4"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3.3"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3.2"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3.1"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.10"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.9"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.8"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.7"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.6"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.5"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.1"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2"];
    array = @[@" Version/4.0.5", @" Safari/6531.22.7"];
    [self.browserUserAgentDict setObject:array forKey:@"4.1"];
}

- (NSString*)browserAgentString
{

    NSString *osVersion = [UIDevice currentDevice].systemVersion;
    NSArray *agentStringArray = self.browserUserAgentDict[osVersion];

    NSMutableString *agentString = [NSMutableString stringWithString:self.userAgent];
    NSRange range = [agentString rangeOfString:@"like Gecko)"];

    if (range.location != NSNotFound && range.length) {

        NSInteger theIndex = range.location + range.length;

		if ([agentStringArray objectAtIndex:0]) {
			[agentString insertString:[agentStringArray objectAtIndex:0] atIndex:theIndex];
			[agentString appendString:[agentStringArray objectAtIndex:1]];
		}
        else {
			[agentString insertString:@" Version/unknown" atIndex:theIndex];
			[agentString appendString:@" Safari/unknown"];
		}

    }

    return agentString;
}

- (NSString*)returnDeviceIPAddress {

    NSString *IPAddressToReturn;

    #if TARGET_IPHONE_SIMULATOR
        IPAddressToReturn = [UIDevice localSimulatorIPAddress];
    #else

        IPAddressToReturn = [UIDevice localWiFiIPAddress];

        if(!IPAddressToReturn) {
            IPAddressToReturn = [UIDevice localCellularIPAddress];
        }

    #endif

    return IPAddressToReturn;
}

- (id) traverseResponderChainForUIViewController 
{
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}

- (UIViewController *) firstAvailableUIViewController 
{
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (void)removeUIWebViewBounce:(UIWebView*)theWebView {

    for (id subview in theWebView.subviews) {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            ((UIScrollView *)subview).bounces = NO;
        }
    }

}

- (void)showErrorLabelWithText:(NSString *)text
{
	UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
	label.numberOfLines = 0;
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:12];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor redColor];

	label.text = text;
	[self.view addSubview:label];
}

- (NSString *)extractStringFromContents:(NSString *)beginningString endingString:(NSString *)endingString contents:(NSString *)contents {
    if (!contents) {
        return nil;
    }

	NSMutableString *localContents = [NSMutableString stringWithString:contents];
	NSRange theRangeBeginning = [localContents rangeOfString:beginningString options:NSCaseInsensitiveSearch];
	if (theRangeBeginning.location == NSNotFound) {
		return nil;
	}
	long location = theRangeBeginning.location + theRangeBeginning.length;
	long length = [localContents length] - location;
	NSRange theRangeToSearch = {location, length};
	NSRange theRangeEnding = [localContents rangeOfString:endingString options:NSCaseInsensitiveSearch range:theRangeToSearch];
	if (theRangeEnding.location == NSNotFound) {
		return nil;
	}
	location = theRangeBeginning.location + theRangeBeginning.length ; 
	length = theRangeEnding.location - location;
	if (length == 0) {
		return nil;
	}
	NSRange theRangeToGet = {location, length};
	return [localContents substringWithRange:theRangeToGet];	
}

- (MobFoxAdType)adTypeEnumValue:(NSString*)adType {

    if ([adType isEqualToString:@"vastAd"]) {
        return MobFoxAdTypeVideo;
    }

    if ([adType isEqualToString:@"noAd"]) {
        return MobFoxAdTypeNoAdInventory;
    }

    if ([adType isEqualToString:@"error"]) {
        return MobFoxAdTypeError;
    }
    
    if ([adType isEqualToString:@"textAd"]) {
        return MobFoxAdTypeText;
    }
    
    if ([adType isEqualToString:@"imageAd"]) {
        return MobFoxAdTypeImage;
    }
    
    if ([adType isEqualToString:@"mraidAd"]) {
        return MobFoxAdTypeMraid;
    }

    return MobFoxAdTypeUnknown;
}

- (NSURL *)serverURL
{
	return [NSURL URLWithString:self.requestURL];
}

#pragma mark Properties

#pragma mark - Location

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    self.currentLatitude = latitude;
    self.currentLongitude = longitude;
}

#pragma mark - Ad Request

- (void)requestAd
{
    if(!enableVideoAds) {
        prioritizeVideoAds = NO;
    }
    
    if (self.advertLoaded || self.advertViewActionInProgress || advertRequestInProgress) {
        return;
    }

    if (!delegate)
	{
		[self showErrorLabelWithText:@"MobFoxVideoInterstitialViewDelegate not set"];

		return;
	}
	if (![delegate respondsToSelector:@selector(publisherIdForMobFoxVideoInterstitialView:)])
	{
		[self showErrorLabelWithText:@"MobFoxVideoInterstitialViewDelegate does not implement publisherIdForMobFoxBannerView:"];

		return;
	}

	NSString *publisherId = [delegate publisherIdForMobFoxVideoInterstitialView:self];
	if (![publisherId length])
	{
		[self showErrorLabelWithText:@"MobFoxVideoInterstitialViewDelegate returned invalid publisher ID."];

        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Invalid publisher ID or Publisher ID not set" forKey:NSLocalizedDescriptionKey];

        NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorInventoryUnavailable userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];

		return;
	}
    advertRequestInProgress = YES;
    alreadyRequestedInterstitial = NO;
    alreadyRequestedVideo = NO;
    
    if (enableInterstitialAds && !prioritizeVideoAds) {
        [self performSelectorInBackground:@selector(asyncRequestAdWithPublisherId:) withObject:publisherId];
    } else if(enableVideoAds) {
        [self performSelectorInBackground:@selector(asyncRequestVideoAdWithPublisherId:) withObject:publisherId];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error creating ad- both video and interstitial ads disabled" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        advertRequestInProgress = NO;
        return;
    }
	

}

- (void)asyncRequestAdWithPublisherId:(NSString *)publisherId
{
    alreadyRequestedInterstitial = YES;
	@autoreleasepool
	{
        NSString *mRaidCapable = @"1";
        
        
        NSString *adWidth;
        NSString *adHeight;
        
        int r = arc4random_uniform(50000);
        NSString *random = [NSString stringWithFormat:@"%d", r];
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

        NSString *adStrict = @"0";
        
        NSString *requestType;
        requestedAdOrientation = interfaceOrientation;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
                adWidth = @"320";
                adHeight = @"480";
            } else {
                adWidth = @"480";
                adHeight = @"320";
            }
            requestType = @"iphone_app";
        }
        else
        {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
                adWidth = @"768";
                adHeight = @"1024";
            } else {
                adWidth = @"1024";
                adHeight = @"768";
            }

            requestType = @"ipad_app";
        }
        
        NSString *osVersion = [UIDevice currentDevice].systemVersion;
        
        NSString *requestString;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
        NSString *iosadvid;
        if ([ASIdentifierManager instancesRespondToSelector:@selector(advertisingIdentifier )]) {
            iosadvid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            NSString *o_iosadvidlimit = @"0";
            if (NSClassFromString(@"ASIdentifierManager")) {
                
                if (![ASIdentifierManager sharedManager].advertisingTrackingEnabled) {
                    o_iosadvidlimit = @"1";
                }
            }
            
            requestString=[NSString stringWithFormat:@"c.mraid=%@&c_customevents=1&r_type=banner&o_iosadvidlimit=%@&rt=%@&u=%@&u_wv=%@&u_br=%@&o_iosadvid=%@&v=%@&s=%@&iphone_osversion=%@&r_random=%@",
						   [mRaidCapable stringByUrlEncoding],
						   [o_iosadvidlimit stringByUrlEncoding],
						   [requestType stringByUrlEncoding],
						   [self.userAgent stringByUrlEncoding],
						   [self.userAgent stringByUrlEncoding],
						   [[self browserAgentString] stringByUrlEncoding],
						   [iosadvid stringByUrlEncoding],
						   [SDK_VERSION stringByUrlEncoding],
						   [publisherId stringByUrlEncoding],
						   [osVersion stringByUrlEncoding],
                           [random stringByUrlEncoding]];
            
        } else {
			requestString=[NSString stringWithFormat:@"c.mraid=%@&c_customevents=1&r_type=banner&rt=%@&u=%@&u_wv=%@&u_br=%@&v=%@&s=%@&iphone_osversion=%@&r_random=%@",
                           [mRaidCapable stringByUrlEncoding],
                           [requestType stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [[self browserAgentString] stringByUrlEncoding],
                           [SDK_VERSION stringByUrlEncoding],
                           [publisherId stringByUrlEncoding],
                           [osVersion stringByUrlEncoding],
                           [random stringByUrlEncoding]];
            
        }
#else
        
        requestString=[NSString stringWithFormat:@"c.mraid=%@&c_customevents=1&r_type=banner&rt=%@&u=%@&u_wv=%@&u_br=%@&v=%@&s=%@&iphone_osversion=%@&r_random=%@",
                       [mRaidCapable stringByUrlEncoding],
                       [requestType stringByUrlEncoding],
                       [self.userAgent stringByUrlEncoding],
                       [self.userAgent stringByUrlEncoding],
                       [[self browserAgentString] stringByUrlEncoding],
                       [SDK_VERSION stringByUrlEncoding],
                       [publisherId stringByUrlEncoding],
                       [osVersion stringByUrlEncoding],
                       [random stringByUrlEncoding]];
        
#endif
        NSString *requestStringWithLocation;
        if(locationAwareAdverts && self.currentLatitude && self.currentLongitude)
        {
            NSString *latitudeString = [NSString stringWithFormat:@"%+.6f", self.currentLatitude];
            NSString *longitudeString = [NSString stringWithFormat:@"%+.6f", self.currentLongitude];
            
            requestStringWithLocation = [NSString stringWithFormat:@"%@&latitude=%@&longitude=%@",
                                         requestString,
                                         [latitudeString stringByUrlEncoding],
                                         [longitudeString stringByUrlEncoding]
                                         ];
        }
        else
        {
            requestStringWithLocation = requestString;
        }
        
        NSString *fullRequestString;

        fullRequestString = [NSString stringWithFormat:@"%@&adspace.width=%@&adspace.height=%@&adspace.strict=%@",
                                 requestStringWithLocation,
                                 [adWidth stringByUrlEncoding],
                                 [adHeight stringByUrlEncoding],
                                 [adStrict stringByUrlEncoding]
                                 ];

        if([userGender isEqualToString:@"female"]) {
            fullRequestString = [NSString stringWithFormat:@"%@&demo.gender=f",
                                 fullRequestString];
        } else if([userGender isEqualToString:@"male"]) {
            fullRequestString = [NSString stringWithFormat:@"%@&demo.gender=m",
                                 fullRequestString];
        }
        if(userAge) {
            NSString *age = [NSString stringWithFormat:@"%d",(int)userAge];
            fullRequestString = [NSString stringWithFormat:@"%@&demo.age=%@",
                                 fullRequestString,
                                 [age stringByUrlEncoding]];
        }
        if(keywords) {
            NSString *words = [keywords componentsJoinedByString:@","];
            fullRequestString = [NSString stringWithFormat:@"%@&demo.keywords=%@",
                                 fullRequestString,
                                 words];
            
        }

        
        NSURL *serverURL = [self serverURL];
        
        if (!serverURL) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error - no or invalid requestURL. Please set requestURL" forKey:NSLocalizedDescriptionKey];
            
            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            return;
        }
        
        NSURL *url;
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", serverURL, fullRequestString]];

        
        NSMutableURLRequest *request;
        NSError *error;
        NSURLResponse *response;
        NSData *dataReply;
        
        request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod: @"GET"];
        [request setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
        [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
        
        dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary *headers;
        if ([response respondsToSelector:@selector(allHeaderFields)]) {
            headers = [(NSHTTPURLResponse *)response allHeaderFields];
        }
        
        DTXMLDocument *xml = [DTXMLDocument documentWithData:dataReply];
        
        if (!xml)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error parsing xml response from server" forKey:NSLocalizedDescriptionKey];
            
            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            return;
        }
        NSString *bannerUrlString = [xml.documentRoot getNamedChild:@"imageurl"].text;
        
        if ([bannerUrlString length])
        {
            NSURL *bannerUrl = [NSURL URLWithString:bannerUrlString];
            _bannerImage = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:bannerUrl]];
        }
        
        [self performSelectorOnMainThread:@selector(advertCreateFromXML:) withObject:@[xml, headers] waitUntilDone:YES];
        
	}
    
}


- (void)asyncRequestVideoAdWithPublisherId:(NSString *)publisherId
{
    alreadyRequestedVideo = YES;
	@autoreleasepool
	{
        NSString *mRaidCapable = @"1";
        
        NSString *adWidth = @"320";
        NSString *adHeight = @"480";
        NSString *adStrict = @"0";
        
        int r = arc4random_uniform(50000);
        NSString *random = [NSString stringWithFormat:@"%d", r];
        
        NSString *requestType;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            requestType = @"iphone_app";
        }
        else
        {
            requestType = @"ipad_app";
        }
        
        NSString *osVersion = [UIDevice currentDevice].systemVersion;
        
        NSString *requestString;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
        NSString *iosadvid;
        if ([ASIdentifierManager instancesRespondToSelector:@selector(advertisingIdentifier )]) {
            iosadvid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            NSString *o_iosadvidlimit = @"0";
            if (NSClassFromString(@"ASIdentifierManager")) {
                
                if (![ASIdentifierManager sharedManager].advertisingTrackingEnabled) {
                    o_iosadvidlimit = @"1";
                }
            }
            
            requestString=[NSString stringWithFormat:@"c.mraid=%@&c_customevents=1&r_type=video&r_resp=vast20&o_iosadvidlimit=%@&rt=%@&u=%@&u_wv=%@&u_br=%@&o_iosadvid=%@&v=%@&s=%@&iphone_osversion=%@&r_random=%@",
						   [mRaidCapable stringByUrlEncoding],
						   [o_iosadvidlimit stringByUrlEncoding],
						   [requestType stringByUrlEncoding],
						   [self.userAgent stringByUrlEncoding],
						   [self.userAgent stringByUrlEncoding],
						   [[self browserAgentString] stringByUrlEncoding],
						   [iosadvid stringByUrlEncoding],
						   [SDK_VERSION stringByUrlEncoding],
						   [publisherId stringByUrlEncoding],
						   [osVersion stringByUrlEncoding],
                           [random stringByUrlEncoding]];
            
        } else {
			requestString=[NSString stringWithFormat:@"c.mraid=%@&c_customevents=1&r_type=video&r_resp=vast20&rt=%@&u=%@&u_wv=%@&u_br=%@&v=%@&s=%@&iphone_osversion=%@&r_random=%@",
                           [mRaidCapable stringByUrlEncoding],
                           [requestType stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [self.userAgent stringByUrlEncoding],
                           [[self browserAgentString] stringByUrlEncoding],
                           [SDK_VERSION stringByUrlEncoding],
                           [publisherId stringByUrlEncoding],
                           [osVersion stringByUrlEncoding],
                           [random stringByUrlEncoding]];
            
        }
#else
        
        requestString=[NSString stringWithFormat:@"c.mraid=%@&c_customevents=1&r_type=video&r_resp=vast20&rt=%@&u=%@&u_wv=%@&u_br=%@&v=%@&s=%@&iphone_osversion=%@&r_random=%@",
                       [mRaidCapable stringByUrlEncoding],
                       [requestType stringByUrlEncoding],
                       [self.userAgent stringByUrlEncoding],
                       [self.userAgent stringByUrlEncoding],
                       [[self browserAgentString] stringByUrlEncoding],
                       [SDK_VERSION stringByUrlEncoding],
                       [publisherId stringByUrlEncoding],
                       [osVersion stringByUrlEncoding],
                       [random stringByUrlEncoding]];
        
#endif
        NSString *requestStringWithLocation;
        if(locationAwareAdverts && self.currentLatitude && self.currentLongitude)
        {
            NSString *latitudeString = [NSString stringWithFormat:@"%+.6f", self.currentLatitude];
            NSString *longitudeString = [NSString stringWithFormat:@"%+.6f", self.currentLongitude];
            
            requestStringWithLocation = [NSString stringWithFormat:@"%@&latitude=%@&longitude=%@",
                                         requestString,
                                         [latitudeString stringByUrlEncoding],
                                         [longitudeString stringByUrlEncoding]
                                         ];
        }
        else
        {
            requestStringWithLocation = requestString;
        }
        
        NSString *fullRequestString;
        
        fullRequestString = [NSString stringWithFormat:@"%@&adspace.width=%@&adspace.height=%@&adspace.strict=%@",
                             requestStringWithLocation,
                             [adWidth stringByUrlEncoding],
                             [adHeight stringByUrlEncoding],
                             [adStrict stringByUrlEncoding]
                             ];
        
        if([userGender isEqualToString:@"female"]) {
            fullRequestString = [NSString stringWithFormat:@"%@&demo.gender=f",
                                 fullRequestString];
        } else if([userGender isEqualToString:@"male"]) {
            fullRequestString = [NSString stringWithFormat:@"%@&demo.gender=m",
                                 fullRequestString];
        }
        if(userAge) {
            NSString *age = [NSString stringWithFormat:@"%d",(int)userAge];
            fullRequestString = [NSString stringWithFormat:@"%@&demo.age=%@",
                                 fullRequestString,
                                 [age stringByUrlEncoding]];
        }
        if(keywords) {
            NSString *words = [keywords componentsJoinedByString:@","];
            fullRequestString = [NSString stringWithFormat:@"%@&demo.keywords=%@",
                                 fullRequestString,
                                 words];
            
        }
        
        if(video_min_duration) {
            NSString *minDuration = [NSString stringWithFormat:@"%d",(int)video_min_duration];
            fullRequestString = [NSString stringWithFormat:@"%@&v_dur_min=%@",
                                 fullRequestString,
                                 [minDuration stringByUrlEncoding]];
        }
        
        if(video_max_duration) {
            NSString *maxDuration = [NSString stringWithFormat:@"%d",(int)video_max_duration];
            fullRequestString = [NSString stringWithFormat:@"%@&v_dur_max=%@",
                                 fullRequestString,
                                 [maxDuration stringByUrlEncoding]];
        }
        
        
        NSURL *serverURL = [self serverURL];
        
        if (!serverURL) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error - no or invalid requestURL. Please set requestURL" forKey:NSLocalizedDescriptionKey];
            
            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            return;
        }
        
        NSURL *url;
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", serverURL, fullRequestString]];
        
        
        NSMutableURLRequest *request;
        NSError *error;
        NSURLResponse *response;
        NSData *dataReply;
        
        request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod: @"GET"];
        [request setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
        [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
        
        dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary *headers;
        if ([response respondsToSelector:@selector(allHeaderFields)]) {
            headers = [(NSHTTPURLResponse *)response allHeaderFields];
        }

        DTXMLDocument *xml = [DTXMLDocument documentWithData:dataReply];
        
        if (!xml)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error parsing xml response from server" forKey:NSLocalizedDescriptionKey];
            
            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            return;
        }
        NSString *bannerUrlString = [xml.documentRoot getNamedChild:@"imageurl"].text;
        
        if ([bannerUrlString length])
        {
            NSURL *bannerUrl = [NSURL URLWithString:bannerUrlString];
            _bannerImage = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:bannerUrl]];
        }
        
        [self performSelectorOnMainThread:@selector(advertCreateFromXML:) withObject:@[xml, headers] waitUntilDone:YES];
        
	}
    
}


#pragma mark - Ad Creation

- (void)advertCreateFromXML:(NSArray*)array
{
    DTXMLDocument *xml = [array objectAtIndex:0];
    NSDictionary *headers;
    if([array count] > 1) {
        headers = [array objectAtIndex:1];
    }
    
    
	if ([xml.documentRoot.name isEqualToString:@"error"])
	{
        if (enableInterstitialAds && !alreadyRequestedInterstitial) {
            NSString *publisherId = [delegate publisherIdForMobFoxVideoInterstitialView:self];
            [self performSelectorInBackground:@selector(asyncRequestAdWithPublisherId:) withObject:publisherId];
        } else if (enableVideoAds && !alreadyRequestedVideo) {
            NSString *publisherId = [delegate publisherIdForMobFoxVideoInterstitialView:self];
            [self performSelectorInBackground:@selector(asyncRequestVideoAdWithPublisherId:) withObject:publisherId];
        } else {
            NSString *errorMsg = xml.documentRoot.text;

            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMsg forKey:NSLocalizedDescriptionKey];

            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        }
		return;
	}
    NSString *adType;
    if([xml.documentRoot.name isEqualToString:@"VAST"]) {
        adType = @"vastAd";
    } else {
        adType = [xml.documentRoot.attributes objectForKey:@"type"];
    }
    
    advertTypeCurrentlyPlaying = [self adTypeEnumValue:adType];
    
    videoWasSkipped = NO;
    videoCheckLoadedCount = 0;
    
    //custom events:

    _customEventFullscreen = nil;
    [customEvents removeAllObjects];
    
    if(headers)
    {
        for(NSString* key in headers) {
            if ([key hasPrefix:@"X-CustomEvent"]) {
                @try {
                    NSString* jsonString = [headers objectForKey:key];
                    NSError *error;
                    NSDictionary *json =
                    [NSJSONSerialization JSONObjectWithData: [jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: &error];
                    if(error) {
                        continue;
                    }
                    CustomEvent *customEvent = [[CustomEvent alloc] init];
                    customEvent.className = [json objectForKey:@"class"];
                    customEvent.optionalParameter = [json objectForKey:@"parameter"];
                    customEvent.pixelUrl = [json objectForKey:@"pixel"];
                    [customEvents addObject:customEvent];
                }
                @catch (NSException *exception) {
                    NSLog(@"Error creating custom event");
                }
                
            }
        }
        
    }

    
    if([customEvents count] > 0)
    {
        [self loadCustomEvent];
        if(!_customEventFullscreen)
        {
            [customEvents removeAllObjects];
        }
    }
    //eo custom events
    
    NSString *publisherId = [delegate publisherIdForMobFoxVideoInterstitialView:self];
    switch (advertTypeCurrentlyPlaying) {
        case MobFoxAdTypeVideo:{

            if ([self videoCreateAdvert:xml.documentRoot]) {

                [self checkVideoLoadedAndReadyToPlay];

            } else if (enableInterstitialAds && !alreadyRequestedInterstitial && !_customEventFullscreen) {
                [self performSelectorInBackground:@selector(asyncRequestAdWithPublisherId:) withObject:publisherId];
            } else if(!_customEventFullscreen){
                [self videoFailedToLoad];
            }
            break;
        }
            
        case MobFoxAdTypeText:
        case MobFoxAdTypeImage:
        case MobFoxAdTypeMraid: {
            if ([self interstitialFromBannerCreateAdvert:xml]) {
                if(!_customEventFullscreen) {
                    [self advertCreatedSuccessfully:advertTypeCurrentlyPlaying];
                } else {
                    self.advertLoaded = YES;
                }
            } else if (enableVideoAds && !alreadyRequestedVideo && !_customEventFullscreen) {
                [self performSelectorInBackground:@selector(asyncRequestVideoAdWithPublisherId:) withObject:publisherId];
            } else if(!_customEventFullscreen){
                [self videoFailedToLoad];
            }
            break;
        }
            
        case MobFoxAdTypeNoAdInventory:{
            if (alreadyRequestedInterstitial && enableVideoAds && !alreadyRequestedVideo && !_customEventFullscreen) {
                [self performSelectorInBackground:@selector(asyncRequestVideoAdWithPublisherId:) withObject:publisherId];
            } else if (alreadyRequestedVideo && enableInterstitialAds && !alreadyRequestedInterstitial && !_customEventFullscreen) {
                [self performSelectorInBackground:@selector(asyncRequestAdWithPublisherId:) withObject:publisherId];
            } else if(!_customEventFullscreen)
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No inventory for ad request" forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorInventoryUnavailable userInfo:userInfo];
                [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            }
                return;

            break;
        }
        case MobFoxAdTypeError:{
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unknown error" forKey:NSLocalizedDescriptionKey];

            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            break;
        }


        default: {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unknown ad type '%@'", adType] forKey:NSLocalizedDescriptionKey];

            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            break;

        }
    }

}

- (void) loadCustomEvent
{
    _customEventFullscreen = nil;
    while ([customEvents count] > 0 && !_customEventFullscreen)
    {
        @try
        {
            CustomEvent *event = [customEvents objectAtIndex:0];
            [customEvents removeObjectAtIndex:0];
            NSString* className = [NSString stringWithFormat:@"%@CustomEventFullscreen",event.className];
            Class customClass = NSClassFromString(className);
            if(customClass) {
                _customEventFullscreen = [[customClass alloc]init];
                _customEventFullscreen.delegate = self;
                [_customEventFullscreen loadFullscreenWithOptionalParameters:event.optionalParameter trackingPixel:event.pixelUrl];
            } else {
                NSLog(@"custom event for %@ not implemented!",event.className);
            }
        }
        @catch (NSException *exception) {
            _customEventFullscreen = nil;
            NSLog( @"Exception while creating custom event!" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
    }
}

- (BOOL)interstitialFromBannerCreateAdvert:(DTXMLDocument*)document {
    interstitialAutoCloseDisabled = YES;
    interstitialSkipButtonDisplayed = NO;
    
    self.mobFoxInterstitialPlayerViewController = [[MobFoxInterstitialPlayerViewController alloc] init];

    if(UIInterfaceOrientationIsPortrait(requestedAdOrientation))
    {
        adInterstitialOrientation = @"portrait";
    }
    else
    {
        adInterstitialOrientation = @"landscape";
    }

    
    [self updateAllFrames:requestedAdOrientation];
    
    self.mobFoxInterstitialPlayerViewController.adInterstitialOrientation = adInterstitialOrientation;
    self.mobFoxInterstitialPlayerViewController.view.backgroundColor = [UIColor clearColor];
    self.mobFoxInterstitialPlayerViewController.view.frame = self.view.bounds;
//    self.mobFoxInterstitialPlayerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.interstitialHoldingView = [[UIView alloc] initWithFrame:self.view.bounds];
//    self.interstitialHoldingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.interstitialHoldingView.backgroundColor = [UIColor clearColor];
    self.interstitialHoldingView.autoresizesSubviews = YES;
    
    MobFoxBannerView* bannerView = [[MobFoxBannerView alloc] initWithFrame:interstitialHoldingView.frame];

    bannerView.allowDelegateAssigmentToRequestAd = NO;
    bannerView.delegate = self;
    bannerView.adspaceHeight = interstitialHoldingView.bounds.size.height;
    bannerView.adspaceWidth = interstitialHoldingView.bounds.size.width;

    bannerView.refreshTimerOff = YES;
    
    bannerView._bannerImage = _bannerImage;

    [bannerView performSelectorOnMainThread:@selector(setupAdFromXml:) withObject:@[document] waitUntilDone:YES];
    
    [self.interstitialHoldingView addSubview:bannerView];
    
    interstitialSkipButtonShow = YES;
    
    UIImage *buttonImage = [UIImage mobfoxSkipButtonImage];
    UIImage *buttonDisabledImage = buttonDisabledImage = [UIImage mobfoxSkipButtonDisabledImage];
    
    float skipButtonSize = buttonSize + 4.0f;
                
    self.interstitialSkipButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.interstitialSkipButton setFrame:CGRectMake(0, 0, skipButtonSize, skipButtonSize)];
    [self.interstitialSkipButton addTarget:self action:@selector(interstitialSkipAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.interstitialSkipButton setImage:buttonImage forState:UIControlStateNormal];
    [self.interstitialSkipButton setImage:buttonDisabledImage forState:UIControlStateHighlighted];
  
    self.interstitialSkipButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self showInterstitialSkipButton];
    return [bannerView isBannerLoaded];
}


- (NSInteger)getTimeFromString:(NSString*)string {
    
    NSArray *components = [string componentsSeparatedByString:@":"];
    
    NSInteger hours   = [[components objectAtIndex:0] integerValue];
    NSInteger minutes = [[components objectAtIndex:1] integerValue];
    NSInteger seconds = [[components objectAtIndex:2] integerValue];
    
    return (hours * 60 * 60) + (minutes * 60) + seconds;
}

- (BOOL)videoCreateAdvert:(DTXMLElement*)videoElement {
    vastAds = [VASTXMLParser parseVAST: videoElement];
    videoSkipButtonDisplayed = NO;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];;
    [self updateAllFrames:interfaceOrientation];
    
    if(vastAds)
    {
        VAST_Ad *vastAd;
        VAST_Linear *linear;
        VAST_MediaFile *mediaFile;
        
        for(VAST_Ad* ad in vastAds) {
            if(ad.InLine) {
                for(VAST_Creative* c in ad.InLine.creatives) {
                    if(c.linear && c.linear.mediaFiles.count != 0)
                    {
                        vastAd = ad;
                        linear = c.linear;
                        mediaFile = [c.linear.mediaFiles objectAtIndex:0];
                        break;
                    }
                }
            }
            if(mediaFile) break;
        }
        
        if(!mediaFile)
        {
            return NO;
        }
        
        NSString *adVideoURL = mediaFile.url;
        
        NSMutableArray *videoTrackingEvents = [NSMutableArray arrayWithArray: linear.trackingEvents];
        if(!adVideoURL)
        {
            return NO;
        }
        [self advertAddNotificationObservers:MobFoxAdGroupVideo];
        videoCheckLoadedCount = 0;
        videoVideoFailedToLoad = NO;

        self.mobFoxVideoPlayerViewController = [[MobFoxVideoPlayerViewController alloc] init];
        self.mobFoxVideoPlayerViewController.adVideoOrientation = adVideoOrientation;
        self.mobFoxVideoPlayerViewController.view.backgroundColor = [UIColor clearColor];
        
        self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:adVideoURL]];
        
        [self.videoPlayer prepareToPlay];
        
        self.videoPlayer.view.backgroundColor = [UIColor blackColor];
        self.videoPlayer.view.frame = self.view.bounds;
        self.videoPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.mobFoxVideoPlayerViewController.view.frame = self.view.bounds;
        self.mobFoxVideoPlayerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.videoPlayer.controlStyle = MPMovieControlStyleNone;
        self.videoPlayer.shouldAutoplay = NO;
        
        videoDuration = [self getTimeFromString:linear.duration];
        
        if (videoVideoFailedToLoad) {
            return NO;
        }
        
        videoSkipButtonShow = YES;
        
        if(videoSkipButtonShow) {
            if(linear.skipoffset) {
                videoSkipButtonDisplayDelay = (NSTimeInterval)[self getTimeFromString:linear.skipoffset];
            } else {
                videoSkipButtonDisplayDelay = 0;
            }
            UIImage *buttonImage;
            UIImage *buttonDisabledImage;
            
            buttonImage = [UIImage mobfoxSkipButtonImage];
            buttonDisabledImage = [UIImage mobfoxSkipButtonDisabledImage];
            
            if (buttonImage) {
                float skipButtonSize = buttonSize + 4.0f;
                
                self.videoSkipButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [self.videoSkipButton setFrame:CGRectMake(0, 0, skipButtonSize, skipButtonSize)];
                [self.videoSkipButton addTarget:self action:@selector(videoSkipAction:) forControlEvents:UIControlEventTouchUpInside];
                [self.videoSkipButton setImage:buttonImage forState:UIControlStateNormal];
                [self.videoSkipButton setImage:buttonDisabledImage forState:UIControlStateHighlighted];
                
                self.videoSkipButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
                
            }
            
        }
        
        if (videoVideoFailedToLoad) {
            return NO;
        }
        
 
        
        VAST_NonLinear *nonLinear;
        for (VAST_Creative *creative in vastAd.InLine.creatives)
        {
            for (VAST_NonLinear *nonL in creative.nonLinearAds.nonLinears)
            {
                if (nonL)
                {
                    nonLinear = nonL;
                    [videoTrackingEvents addObjectsFromArray:creative.nonLinearAds.trackingEvents];
                    HTMLOverlayHeight = nonLinear.height;
                    HTMLOverlayWidth = nonLinear.width;
                    break;
                }
            }
            if(nonLinear)
                break;
        }
        
        
        self.videoAdvertTrackingEvents = [NSMutableArray arrayWithCapacity:0];
        
        if ([videoTrackingEvents count]) {
            
            for (VAST_Tracking *tracking in videoTrackingEvents)
            {
                
                NSString *type = tracking.event;
                NSString *clickUrl = tracking.url;
                
                if (clickUrl && type) {
                    NSDictionary *trackingEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   clickUrl, type,
                                                   nil];
                    
                    [self.videoAdvertTrackingEvents addObject:trackingEvent];
                }
                
            }
        }
        
        if (nonLinear.nonLinearClickTracking) {
               NSDictionary *trackingEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                              nonLinear.nonLinearClickTracking, @"overlayClick",
                                              nil];
                
               [self.videoAdvertTrackingEvents addObject:trackingEvent];
        }
        for (NSString* click in linear.videoClicks.clickTracking) {
              NSDictionary *trackingEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                             click, @"videoClick",
                                             nil];
                
             [self.videoAdvertTrackingEvents addObject:trackingEvent];
        }
            
        for (VAST_Impression* impression in  vastAd.InLine.impressions) {
              NSDictionary *trackingEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                             impression.url, @"Impression",
                                             nil];
                
             [self.videoAdvertTrackingEvents addObject:trackingEvent];
        }
            
        
        
        
        videoHTMLOverlayDisplayDelay = (NSTimeInterval)0;
        
        if(nonLinear.staticResource)
        {
            NSString *resource;
            NSString *type = nonLinear.staticResource.type;
            if([type isEqualToString:@"image/gif"] || [type isEqualToString:@"image/jpeg"] || [type isEqualToString:@"image/png"])
            {
                resource = [NSString stringWithFormat:@"<body style=\"margin: 0px; padding: 0px; text-align:center; width:100%%; height:100%%\"><img src=\"%@\"></body>", nonLinear.staticResource.url];
                
                self.videoHTMLOverlayHTML = resource;
            }
            else if([type isEqualToString:@"application/x-javascript"])
            {
                resource = [NSString stringWithFormat:@"<script src=\"%@\"></script>", nonLinear.staticResource.url];
                self.videoHTMLOverlayHTML = resource;
            }
        }
        else if(nonLinear.iFrameResource)
        {
            NSString *resource = [NSString stringWithFormat:@"<iframe src=\"%@\"></iframe>", nonLinear.iFrameResource];
            self.videoHTMLOverlayHTML = resource;
        }
        else if(nonLinear.htmlResource)
        {
            self.videoHTMLOverlayHTML = nonLinear.htmlResource;
        }
        if(nonLinear.nonLinearClickThrough) {
            _overlayClickThrough = [nonLinear.nonLinearClickThrough stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        if (linear.videoClicks.clickThrough)
        {
            UIView *coveringView = [[UIView alloc] initWithFrame:self.videoPlayer.view.bounds];
            _videoClickThrough = [linear.videoClicks.clickThrough stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoClick:)];
            singleTap.delegate = self;
            
            [coveringView addGestureRecognizer:singleTap];
            
            coveringView.backgroundColor = [UIColor clearColor];
            
            coveringView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            [self.videoPlayer.view addSubview:coveringView];

        }
        

        UIColor *buttonBackground = [UIColor colorWithWhite:0.95 alpha:0.9f];
        
        videoClickButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        videoClickButton.userInteractionEnabled = NO; //video covering view will be clicked instead of button
        [videoClickButton setTitle:@"Click here" forState:UIControlStateNormal];
        videoClickButton.bounds = CGRectMake(0, 0, videoEndButtonWidth, videoEndButtonHeight);
        videoClickButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        videoClickButton.backgroundColor = buttonBackground;
        videoClickButton.hidden = YES;
        [videoClickButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [videoClickButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, videoClickButton.frame.size.height - 1.0f, videoClickButton.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor darkGrayColor];
        [videoClickButton addSubview:bottomBorder];
        
        [self.videoPlayer.view addSubview:videoClickButton];
        
        videoReplayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [videoReplayButton addTarget:self action:@selector(videoReplayButtonAction:)
                    forControlEvents:UIControlEventTouchUpInside];
        [videoReplayButton setTitle:@"↻" forState:UIControlStateNormal];
        videoReplayButton.bounds = CGRectMake(0, 0, videoEndButtonWidth, videoEndButtonHeight);
        videoReplayButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        videoReplayButton.backgroundColor = buttonBackground;
        videoReplayButton.hidden = YES;
        [videoReplayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [videoReplayButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, videoReplayButton.frame.size.width, 1)];
        topBorder.backgroundColor = [UIColor darkGrayColor];
        [videoReplayButton addSubview:topBorder];
        
        [self.videoPlayer.view addSubview:videoReplayButton];
        
        videoTimerShow = YES;
        videoTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
        [videoTimerLabel setFont:[UIFont boldSystemFontOfSize:14]];
        videoTimerLabel.backgroundColor = [UIColor blackColor];
        videoTimerLabel.textColor = [UIColor whiteColor];
        int minutes = floor(videoDuration/60);
        int seconds = trunc(videoDuration - minutes * 60);
        videoTimerLabel.text = [NSString stringWithFormat:@" -%i:%.2d ", minutes, seconds];
        
        [videoTimerLabel sizeToFit];
        videoTimerLabel.layer.cornerRadius = 6;
        videoTimerLabel.layer.masksToBounds = YES;
        
       [self.videoPlayer.view addSubview:videoTimerLabel];
        
        
        if (videoVideoFailedToLoad) {
            return NO;
        }
        
        return YES;
    }
    else
    {
        return NO;
    }

}

- (void)advertCreationFailed {

    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Advert could not be created" forKey:NSLocalizedDescriptionKey];

    NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
    [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
}

- (void)advertCreatedSuccessfully:(MobFoxAdType)advertType {

    NSNumber *advertTypeNumber = [NSNumber numberWithInt:advertType];
    [self performSelectorOnMainThread:@selector(reportSuccess:) withObject:advertTypeNumber waitUntilDone:YES];
}

- (void)checkVideoLoadedAndReadyToPlay {
    if (videoVideoFailedToLoad || videoCheckLoadedCount > 100) {
        [self videoFailedToLoad];

    } else {
        if ([self.videoPlayer loadState] == MPMovieLoadStateUnknown) {
            videoCheckLoadedCount++;

            [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(checkVideoLoadedAndReadyToPlay) userInfo:nil repeats:NO];
            return;
        }
        if(!_customEventFullscreen) {
            [self advertCreatedSuccessfully:MobFoxAdTypeVideo];
        } else {
            self.advertLoaded = YES;
        }
    }

}

- (void)videoFailedToLoad {
    [self advertCreationFailed];

    videoWasSkipped = NO;

    [self advertTidyUpAfterAd:MobFoxAdTypeVideo];

}

#pragma mark - CustomEventFullscreenDelegate methods
-(UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)customEventFullscreenDidLoadAd:(CustomEventFullscreen *)fullscreen
{
    [self advertCreatedSuccessfully:advertTypeCurrentlyPlaying];
}

- (void)customEventFullscreenDidFailToLoadAd
{
    [self loadCustomEvent];
    if(_customEventFullscreen) {
        return;
    } else if(advertLoaded) {
        [self advertCreatedSuccessfully:advertTypeCurrentlyPlaying];
        return;
    } else if (enableInterstitialAds && !alreadyRequestedInterstitial && !_customEventFullscreen) {
        NSString *publisherId = [delegate publisherIdForMobFoxVideoInterstitialView:self];
        [self performSelectorInBackground:@selector(asyncRequestAdWithPublisherId:) withObject:publisherId];
    } else if (enableVideoAds && !alreadyRequestedVideo && !_customEventFullscreen) {
        NSString *publisherId = [delegate publisherIdForMobFoxVideoInterstitialView:self];
        [self performSelectorInBackground:@selector(asyncRequestVideoAdWithPublisherId:) withObject:publisherId];
    } else {
        [self advertCreationFailed];
    }
}

- (void)customEventFullscreenWillAppear
{
    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewActionWillPresentScreen:)])
	{
		[delegate mobfoxVideoInterstitialViewActionWillPresentScreen:self];
	}
}

- (void)customEventFullscreenWillClose
{
    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWillDismissScreen:)])
	{
		[delegate mobfoxVideoInterstitialViewWillDismissScreen:self];
	}
    [self advertTidyUpAfterAd:currentlyPlayingInterstitial];
}

- (void)customEventFullscreenWillLeaveApplication
{
    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWasClicked:)])
    {
        [delegate mobfoxVideoInterstitialViewWasClicked:self];
    }

    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewActionWillLeaveApplication:)])
    {
        [delegate mobfoxVideoInterstitialViewActionWillLeaveApplication:self];
    }
}

#pragma mark - Ad Presentation
- (void)presentCustomEventFullscreen {
    @try {
        [_customEventFullscreen showFullscreenFromRootViewController:[self firstAvailableUIViewController]];
    }
    @catch (NSException *exception) {
        _customEventFullscreen = nil;
        [self advertTidyUpAfterAd:currentlyPlayingInterstitial];
        [self advertCreationFailed];
    }
    
}


- (void)presentAd:(MobFoxAdType)advertType {

    switch (advertType) {
        case MobFoxAdTypeVideo:
            if(_customEventFullscreen) {
                [self presentCustomEventFullscreen];
            }
            else if (self.videoPlayer.view) {
                tempView = [[UIView alloc]initWithFrame:self.videoPlayer.view.frame];
                tempView.backgroundColor = [UIColor blackColor];
                [self.view addSubview:tempView];

                [self.mobFoxVideoPlayerViewController.view addSubview:self.videoPlayer.view];

                videoViewController = [self firstAvailableUIViewController];

                videoViewController.wantsFullScreenLayout = YES;

                [videoViewController presentModalViewController:self.mobFoxVideoPlayerViewController animated:NO];

                [self advertShow:advertType viewToShow:self.mobFoxVideoPlayerViewController.view];

            }
            break;
        case MobFoxAdTypeMraid:
        case MobFoxAdTypeImage:
        case MobFoxAdTypeText:
            if(_customEventFullscreen) {
                [self presentCustomEventFullscreen];
            }
            else if (self.interstitialHoldingView) {

                [self.mobFoxInterstitialPlayerViewController.view addSubview:self.interstitialHoldingView];

                interstitialViewController = [self firstAvailableUIViewController];

                interstitialViewController.wantsFullScreenLayout = YES;

                [interstitialViewController presentModalViewController:self.mobFoxInterstitialPlayerViewController animated:NO];

                [self advertShow:advertType viewToShow:self.mobFoxInterstitialPlayerViewController.view];

            }
            break;
        case MobFoxAdTypeUnknown:
        case MobFoxAdTypeError:
            break;
        case MobFoxAdTypeNoAdInventory:
            if(_customEventFullscreen) {
                [self presentCustomEventFullscreen];
            }
            break;
    }

}

- (void)interstitialStopAdvert {
    currentlyPlayingInterstitial = NO;

    [self advertRemoveNotificationObservers:MobFoxAdGroupInterstitial];

    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWillDismissScreen:)])
	{
		[delegate mobfoxVideoInterstitialViewWillDismissScreen:self];
	}
    
    [self advertTidyUpAfterAd:advertTypeCurrentlyPlaying];
    [interstitialViewController dismissModalViewControllerAnimated:NO];
    [self interstitialTidyUpAfterAd];

}

- (void)interstitialTidyUpAfterAd {
    
    if (self.interstitialWebView) {
        
        [self interstitialStopTimer];
        
        [self.interstitialTopToolbar removeFromSuperview];
        [self.interstitialBottomToolbar removeFromSuperview];
        
        self.interstitialTopToolbar = nil;
        self.interstitialBottomToolbar = nil;
        
        self.interstitialSkipButton = nil;
        
        interstitialSkipButtonDisplayed = NO;
        
        self.interstitialWebView.delegate = nil;
        [self.interstitialWebView removeFromSuperview];
        self.interstitialWebView = nil;
        
        [self.interstitialHoldingView removeFromSuperview];
        self.interstitialHoldingView = nil;
        
    }
}

- (void)videoPlayAdvert {

    if ([self.videoPlayer loadState] == MPMovieLoadStateUnknown) {
        [self.videoPlayer prepareToPlay];

        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(videoPlayAdvert) userInfo:nil repeats:NO];
        return;
    } else {
        [self advertAddNotificationObservers:MobFoxAdGroupVideo];

        [self videoStartTimer];
        [self advertActionTrackingEvent:@"start"];
        [self advertActionTrackingEvent:@"Impression"];
        [self advertActionTrackingEvent:@"creativeView"];
        [self.videoPlayer play];

    }

}

- (void)videoStopAdvert {
    [self advertRemoveNotificationObservers:MobFoxAdGroupVideo];
    
    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWillDismissScreen:)])
	{
		[delegate mobfoxVideoInterstitialViewWillDismissScreen:self];
	}
    
    [self advertTidyUpAfterAd:advertTypeCurrentlyPlaying];
    
//    [videoViewController dismissModalViewControllerAnimated:NO];
    [self videoTidyUpAfterAd];
}

- (void)playAdvert:(MobFoxAdType)advertType {

    if (!self.advertViewActionInProgress) {
        switch (advertType) {
            case MobFoxAdTypeVideo:
                [self videoPlayAdvert];
                break;
            case MobFoxAdTypeUnknown:
            case MobFoxAdTypeError:
            case MobFoxAdTypeImage:
            case MobFoxAdTypeText:
            case MobFoxAdTypeMraid:
            case MobFoxAdTypeNoAdInventory:
                break;
        }

        return;
    }

    self.advertViewActionInProgress = YES;

}

#pragma mark - Ad presentation

- (void)advertShow:(MobFoxAdType)advertType viewToShow:(UIView*)viewToShow {
    if (advertTypeCurrentlyPlaying == advertType) {

        if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewActionWillPresentScreen:)])
        {
            [delegate mobfoxVideoInterstitialViewActionWillPresentScreen:self];
        }

        [self hideStatusBar];

    }

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];;
    [self updateAllFrames:interfaceOrientation];

    viewToShow.alpha = 1.0f;
    viewToShow.hidden = NO;
    [self playAdvert:advertType];
    

}

- (void)advertTidyUpAfterAd:(MobFoxAdType)advertType {

    [self showStatusBarIfNecessary];

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];;
    [self updateAllFrames:interfaceOrientation];

    if (advertType == MobFoxAdTypeVideo) {
        [videoViewController dismissModalViewControllerAnimated:NO]; 
        [self videoTidyUpAfterAd];
    }

    self.view.hidden = YES;
    self.view.alpha = 0.0;

    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewDidDismissScreen:)])
    {
        [delegate mobfoxVideoInterstitialViewDidDismissScreen:self];
    }

    self.advertViewActionInProgress = NO;
    self.advertLoaded = NO;

}


- (void)videoTidyUpAfterAd {

    if (self.videoPlayer) {
        if (self.videoPlayer.playbackState != MPMoviePlaybackStateStopped ) {
            [self.videoPlayer stop];
        }

        [self videoStopTimer];

        self.videoHTMLOverlayWebView = nil;
        self.videoBottomToolbar = nil;
        self.videoTopToolbar = nil;
        self.videoReplayButton = nil;
        self.videoClickButton = nil;
        self.videoTimerLabel = nil;

        self.videoSkipButton = nil;

        videoHtmlOverlayDisplayed = NO;
        videoSkipButtonDisplayed = NO;

        [self.videoPlayer.view removeFromSuperview];

        self.videoPlayer = nil;

        self.mobFoxVideoPlayerViewController = nil;

        [tempView removeFromSuperview];

    }

}


#pragma mark - Request Status Reporting

- (void)reportSuccess:(NSNumber*)advertTypeNumber
{
    advertRequestInProgress = NO;

    MobFoxAdType advertType = (MobFoxAdType)[advertTypeNumber intValue];

    self.advertLoaded = YES;
	if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewDidLoadMobFoxAd:advertTypeLoaded:)])
	{
		[delegate mobfoxVideoInterstitialViewDidLoadMobFoxAd:self advertTypeLoaded:advertType];
	}
}

- (void)reportError:(NSError *)error
{

    advertRequestInProgress = NO;

    self.advertLoaded = NO;
	if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialView:didFailToReceiveAdWithError:)])
	{
		[delegate mobfoxVideoInterstitialView:self didFailToReceiveAdWithError:error];
	}
}

#pragma mark - Frame Sizing

- (void)updateAllFrames:(UIInterfaceOrientation)interfaceOrientation {

    [self applyFrameSize:interfaceOrientation];

    if (self.videoPlayer.view) {
        self.videoPlayer.view.frame = self.view.bounds;
    }
    if(videoClickButton) {
        videoClickButton.center = CGPointMake(self.videoPlayer.view.center.x, self.videoPlayer.view.center.y - videoEndButtonHeight/2);
    }
    if(videoReplayButton) {
        videoReplayButton.center = CGPointMake(self.videoPlayer.view.center.x, self.videoPlayer.view.center.y + videoEndButtonHeight/2);
    }
    
    if(videoTimerLabel) {
        videoTimerLabel.center = CGPointMake([self getResizedVideoFrame].size.width - videoTimerLabel.frame.size.width/2, self.videoPlayer.view.bounds.size.height/2 + [self getResizedVideoFrame].size.height/2 - videoTimerLabel.frame.size.height/2);
    }

    if (self.videoHTMLOverlayWebView) {
        self.videoHTMLOverlayWebView.frame = [self returnVideoHTMLOverlayFrame];
    }

    if (self.interstitialWebView) {
        self.interstitialWebView.frame = [self returnInterstitialWebFrame];
    }

    if (tempView) {
        tempView.frame = [self returnVideoHTMLOverlayFrame];
    }

}

- (void)applyFrameSize:(UIInterfaceOrientation)interfaceOrientation {

     CGSize size = [UIScreen mainScreen].bounds.size;

    if (UIInterfaceOrientationIsPortrait(interfaceOrientation) ||
        [[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) { //version higher or equal to iOS 8
        self.view.frame = CGRectMake(0, 0, size.width, size.height);
    } else {
        self.view.frame = CGRectMake(0, 0, size.height, size.width);
    }

}

- (CGRect)returnInterstitialWebFrame {

    float topToolbarHeight = 0.0f;
    float bottomToolbarHeight = 0.0f;

    if (self.interstitialTopToolbar) {
        topToolbarHeight = self.interstitialTopToolbar.frame.size.height;
    }

    if (self.interstitialBottomToolbar) {
        bottomToolbarHeight = self.interstitialBottomToolbar.frame.size.height;
    }
    CGRect webFrame = CGRectMake(0, topToolbarHeight, self.view.bounds.size.width, self.view.bounds.size.height - topToolbarHeight - bottomToolbarHeight);

    return webFrame;

}

- (CGRect)returnVideoHTMLOverlayFrame {

    CGRect webFrame = CGRectMake(0, self.view.bounds.size.height-HTMLOverlayHeight, HTMLOverlayWidth, HTMLOverlayHeight);

    webFrame.origin.x = self.view.center.x - HTMLOverlayWidth/2;
    return webFrame;
}

-(CGRect)getResizedVideoFrame {
    CGSize naturalSize = self.videoPlayer.naturalSize;
    CGRect playerSize = self.videoPlayer.view.bounds;
    
    float resVi = naturalSize.width / naturalSize.height;
    float resPl = playerSize.size.width / playerSize.size.height;
    return (resPl > resVi ? CGRectMake(0, 0, naturalSize.width * playerSize.size.height/naturalSize.height, playerSize.size.height) : CGRectMake(0, 0,playerSize.size.width, naturalSize.height * playerSize.size.width/naturalSize.width));
}


#pragma mark - Timers

- (void)videoStalledStartTimer {

    stalledVideoStartTime = [self.videoPlayer currentPlaybackTime];

    if(![self.videoStalledTimer isValid]) {
        self.videoStalledTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self 
                                                                selector:@selector(checkForStalledVideo) userInfo:nil repeats:NO];

    }

}

- (void)videoStalledStopTimer {

    if([self.videoStalledTimer isValid]) {
        [self.videoStalledTimer invalidate];
        self.videoStalledTimer = nil;
    }

}

- (void)checkForStalledVideo {

    NSTimeInterval currentPlayBack = [self.videoPlayer currentPlaybackTime];

    if(currentPlayBack - stalledVideoStartTime < 3) {

        if(!videoSkipButtonDisplayed) {
                [self videoShowSkipButton];

        }

    }

}

- (void)videoStartTimer {

    if (!self.videoTimer) {
        self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self 
                                                         selector:@selector(updateVideoTimer) userInfo:nil repeats:YES];
    }

}

- (void)videoStopTimer {

    if([self.videoTimer isValid]) {
        [self.videoTimer invalidate];
        self.videoTimer = nil;
    }

}

- (void)interstitialStartTimer {

    self.timerStartTime = [NSDate date];

    self.interstitialTimer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self 
                                                            selector:@selector(updateInterstitialTimer) userInfo:nil repeats:YES];

}

- (void)interstitialStopTimer {

    if([self.interstitialTimer isValid]) {
        [self.interstitialTimer invalidate];
        self.interstitialTimer = nil;
    }

    self.timerStartTime = nil;

}

#pragma mark Timer Action Selectors

- (void)videoShowSkipButton {

    if (videoSkipButtonDisplayed) {
        return;
    }

    if (self.videoTopToolbar) {
        self.videoTopToolbar.items = self.videoTopToolbarButtons;
    } else {
        float skipButtonSize = buttonSize + 4.0f;
        CGRect buttonFrame = self.videoSkipButton.frame;
        buttonFrame.origin.x = self.view.frame.size.width - (skipButtonSize+10.0f);
        buttonFrame.origin.y = 10.0f;

        self.videoSkipButton.frame = buttonFrame;

        [self.videoPlayer.view addSubview:self.videoSkipButton];
    }

    videoSkipButtonDisplayed = YES;
}

- (void)showOnVideoEndButtons {
    videoReplayButton.hidden = NO;
    videoClickButton.center = CGPointMake(self.videoPlayer.view.center.x, self.videoPlayer.view.center.y - videoEndButtonHeight/2);
    videoReplayButton.center = CGPointMake(self.videoPlayer.view.center.x, self.videoPlayer.view.center.y + videoEndButtonHeight/2);
    
    videoTimerLabel.hidden = YES;
    videoClickButton.hidden = NO;
}

- (void) hideOnVideoEndButtons {
    videoClickButton.hidden = YES;
    videoReplayButton.hidden = YES;
    videoTimerLabel.hidden = NO;
}
- (void)showInterstitialSkipButton {

    if (interstitialSkipButtonDisplayed) {
        return;
    }

    if (self.interstitialTopToolbar) {
        self.interstitialTopToolbar.items = self.interstitialTopToolbarButtons;
    } else {
        float skipButtonSize = buttonSize + 4.0f;
        CGRect buttonFrame = self.interstitialSkipButton.frame;
        buttonFrame.origin.x = self.view.frame.size.width - (skipButtonSize+10.0f);
        buttonFrame.origin.y = 10.0f;

        self.interstitialSkipButton.frame = buttonFrame;

        [self.interstitialHoldingView addSubview:self.interstitialSkipButton]; 
    }

    interstitialSkipButtonDisplayed = YES;
}

- (void)videoShowHTMLOverlay {

    self.videoHTMLOverlayWebView = [[UIWebView alloc]initWithFrame:[self returnVideoHTMLOverlayFrame]];
    self.videoHTMLOverlayWebView.delegate = (id)self;
    self.videoHTMLOverlayWebView.dataDetectorTypes = UIDataDetectorTypeAll;

//    self.videoHTMLOverlayWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self removeUIWebViewBounce:self.videoHTMLOverlayWebView];

    [self.videoHTMLOverlayWebView loadHTMLString:self.videoHTMLOverlayHTML baseURL:nil];
    self.videoHTMLOverlayWebView.backgroundColor = [UIColor clearColor];
    self.videoHTMLOverlayWebView.opaque = NO;
    
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOverlayClick:)];
    touch.delegate = self;
    [self.videoHTMLOverlayWebView addGestureRecognizer:touch];

    [self.videoPlayer.view addSubview:self.videoHTMLOverlayWebView];

    if(videoSkipButtonShow) {
        if(videoSkipButtonDisplayed) {
            [self.videoPlayer.view bringSubviewToFront:videoSkipButton]; 
        }
    }

}

- (void)updateVideoTimerLabel:(NSTimeInterval)progress {
    if(videoTimerShow) {
        float countDownProgress = videoDuration - progress;
        
        if(countDownProgress >= 0) {
            int minutes = floor(countDownProgress/60);
            int seconds = trunc(countDownProgress - minutes * 60);
            self.videoTimerLabel.text = [NSString stringWithFormat:@" -%i:%.2d ", minutes, seconds];
        }
    }

}

- (void)updateVideoTimer {

    NSTimeInterval currentProgress = [self.videoPlayer currentPlaybackTime];
    [self updateVideoTimerLabel:currentProgress];

    int timeToCheckAgainst = (int)roundf(currentProgress);
    if (videoDuration != 0) {
        if (timeToCheckAgainst == videoDuration/2) {
            [self advertActionTrackingEvent:@"midpoint"];
        }

        NSInteger quartile = videoDuration/4;
        if (timeToCheckAgainst == quartile) {
            [self advertActionTrackingEvent:@"firstQuartile"];
        }
        if (timeToCheckAgainst == (quartile*3)) {
            [self advertActionTrackingEvent:@"thirdQuartile"];
        }
    }

//    [self advertActionTrackingEvent:[NSString stringWithFormat:@"sec:%d", timeToCheckAgainst]];

    if(!videoSkipButtonDisplayed) {
        if(videoSkipButtonShow) {
            if(videoSkipButtonDisplayDelay == timeToCheckAgainst) {
                [self videoShowSkipButton];
            }
        }
    }

    if(!videoHtmlOverlayDisplayed) {
        if (self.videoHTMLOverlayHTML) {
            if(videoHTMLOverlayDisplayDelay == timeToCheckAgainst) {
                [self videoShowHTMLOverlay];
                videoHtmlOverlayDisplayed = YES;
            }
        }
    }
}

- (void)updateInterstitialTimer {

    NSDate *currentDate = [NSDate date];
    NSTimeInterval progress = [currentDate timeIntervalSinceDate:self.timerStartTime];

    int timeToCheckAgainst = (int)roundf(progress);
    if (!interstitialAutoCloseDisabled) {
        if (timeToCheckAgainst == interstitialAutoCloseDelay) {

            [self interstitialStopTimer];

            [self interstitialSkipAction:nil];

            return;
        }
    }

    if(!interstitialSkipButtonDisplayed) {
        if(interstitialSkipButtonShow) {
            if(interstitialSkipButtonDisplayDelay == timeToCheckAgainst) {
                [self showInterstitialSkipButton];
            }
        }
    }

    if(interstitialTimerShow) {

        float countDownProgress = interstitialAutoCloseDelay - progress;

        int minutes = floor(countDownProgress/60);
        int seconds = trunc(countDownProgress - minutes * 60);
        self.interstitialTimerLabel.text = [NSString stringWithFormat:@"%i:%.2d", minutes, seconds];
    }
}

#pragma mark Video Control

- (void)videoPause {

    [self advertActionTrackingEvent:@"pause"];

    [self.videoPlayer pause];
    [self videoStopTimer];

}

- (void)videoUnPause {

    [self advertActionTrackingEvent:@"resume"];

    [self.videoPlayer play];

    [self videoStartTimer];

}

#pragma mark - Interaction

- (void)tapThrough:(BOOL)tapThroughLeavesApp tapThroughURL:(NSURL*)tapThroughURL
{
    tapThroughLeavesApp = YES;

	if (tapThroughLeavesApp || [tapThroughURL isDeviceSupported])
	{

        if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewActionWillLeaveApplication:)])
        {
            [delegate mobfoxVideoInterstitialViewActionWillLeaveApplication:self];
        }

        [[UIApplication sharedApplication]openURL:tapThroughURL];
		return;
	}
    if (!advertTypeCurrentlyPlaying == MobFoxAdTypeVideo) {
        viewController = [self firstAvailableUIViewController]; 
    }

	MobFoxAdBrowserViewController *browser = [[MobFoxAdBrowserViewController alloc] initWithUrl:tapThroughURL];
    browser.delegate = (id)self;
	browser.userAgent = self.userAgent;
    browser.webView.scalesPageToFit = YES;
	browser.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    if (self.videoPlayer.playbackState == MPMoviePlaybackStatePlaying ) {
        videoWasPlaying = YES;
        [self videoPause];
    } else {
        videoWasPlaying = NO;
    }

    if (!advertTypeCurrentlyPlaying == MobFoxAdTypeVideo) {
        [viewController presentModalViewController:browser animated:YES];
    } else {
        [self.mobFoxVideoPlayerViewController.view addSubview:browser.webView];
    }
}

- (void)postTrackingEvent:(NSString*)urlString {

    NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request;

    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: @"GET"];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:nil];
    [connection start];

}

- (void)advertActionTrackingEvent:(NSString*)eventType {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY @allKeys = %@", eventType];

    NSArray *trackingEvents = [self.videoAdvertTrackingEvents filteredArrayUsingPredicate:predicate];

    NSMutableArray *trackingEventsToRemove = [NSMutableArray arrayWithCapacity:0];

	for (NSDictionary *trackingEvent in trackingEvents)
	{

        NSString *urlString = [trackingEvent objectForKey:eventType];
        urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (urlString) {

            [self postTrackingEvent:urlString];

            [trackingEventsToRemove addObject:trackingEvent];

        }

	}
    if (![eventType isEqualToString:@"mute"] && ![eventType isEqualToString:@"unmute"] && ![eventType isEqualToString:@"pause"] && ![eventType isEqualToString:@"unpause"] && ![eventType isEqualToString:@"skip"] && ![eventType isEqualToString:@"replay"]) {

        if ([trackingEventsToRemove count]) {
            [self.videoAdvertTrackingEvents removeObjectsInArray:trackingEventsToRemove];
        }

    }

}


#pragma mark Interstitial Interaction

- (void)removeAutoClose {
    interstitialTimerShow = NO;
    [self.interstitialTimerLabel removeFromSuperview];

}

- (void)checkAndCancelAutoClose {

    if (!interstitialAutoCloseDisabled) {

        interstitialAutoCloseDisabled = YES;

        if(self.interstitialWebView) {

            if (interstitialTimerShow) {
                [self removeAutoClose];
            }

        }
    }
    if(!interstitialSkipButtonDisplayed) {
        [self showInterstitialSkipButton];
    }

}

#pragma mark Button Actions

- (void)browserBackButtonAction:(id)sender {

    [self.interstitialWebView goBack];

    [self checkAndCancelAutoClose];

}

- (void)browserForwardButtonAction:(id)sender {

    [self.interstitialWebView goForward];

    [self checkAndCancelAutoClose];

}

- (void)browserReloadButtonAction:(id)sender {

    [self checkAndCancelAutoClose];

}

- (void)browserExternalButtonAction:(id)sender {

    [self checkAndCancelAutoClose];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.interstitialURL]];

}

- (void)videoSkipAction:(id)sender {

    videoWasSkipped = YES;

    [self advertActionTrackingEvent:@"skip"];
    [self advertActionTrackingEvent:@"close"];

    [self videoStopAdvert];
}

- (void)navIconAction:(id)sender {

    UIButton *theButton = (UIButton*)sender;
    NSDictionary *buttonObject = theButton.objectTag;

    BOOL clickleavesApp = [[buttonObject objectForKey:@"openType"] isEqualToString:@"external"];
    NSString *urlString = [buttonObject objectForKey:@"clickUrl"];

    NSString *prefix = [urlString substringToIndex:5];

	if ([prefix isEqualToString:@"mfox:"]) {

        NSString *actionString = [urlString substringFromIndex:5];

        if ([actionString isEqualToString:@"skip"]) {

            [self videoSkipAction:nil];
            return;
        }

        if ([actionString isEqualToString:@"replayvideo"]) {

            [self videoReplayButtonAction:nil];

            return;
        }

    } else {
        NSURL *clickUrl = [NSURL URLWithString:urlString];

        [self tapThrough:clickleavesApp tapThroughURL:clickUrl];

    }

}

- (void)videoPausePlayButtonAction:(id)sender {

    UIButton *theButton = (UIButton*)sender;

    BOOL videoIsPlaying = self.videoPlayer.playbackState != MPMoviePlaybackStatePaused;
    if (videoIsPlaying) {

        [self videoPause];

        [theButton setImage:self.videoPlayButtonImage forState:UIControlStateNormal];
        [theButton setImage:self.videoPlayButtonDisabledImage forState:UIControlStateHighlighted];

        [self videoShowSkipButton];

    } else {

        [self videoUnPause];

        [theButton setImage:self.videoPauseButtonImage forState:UIControlStateNormal];
        [theButton setImage:self.videoPauseButtonDisabledImage forState:UIControlStateHighlighted];
    }
}

- (void)videoReplayButtonAction:(id)sender {
    [self hideOnVideoEndButtons];
    [self advertActionTrackingEvent:@"replay"];

    [self.videoPlayer setCurrentPlaybackTime:0.0];
    if (self.videoPlayer.playbackState != MPMoviePlaybackStatePlaying ) {

        [self updateVideoTimerLabel:0.00];

    }
    [self.videoPlayer play];
}

- (void)interstitialSkipAction:(id)sender {
    [self interstitialStopAdvert];

}

#pragma mark -
#pragma mark Actionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.interstitialURL]];
    }

}

#pragma mark -
#pragma mark MPMoviePlayerController Delegate

- (void)playerLoadStateDidChange:(NSNotification*)notification{

	MPMovieLoadState state = [(MPMoviePlayerController *)notification.object loadState];
	if( state & MPMovieLoadStateUnknown ) {
	}

	if( state & MPMovieLoadStatePlayable ) {

        [self videoStalledStopTimer];

	}
	if( state & MPMovieLoadStatePlaythroughOK ) {

	}
	if( state & MPMovieLoadStateStalled ) {

        [self videoStalledStartTimer];

    }

}

- (void)playerPlayBackStateDidChange:(NSNotification*)notification{

	MPMoviePlaybackState state = [(MPMoviePlayerController *)notification.object playbackState];
	if( state == MPMoviePlaybackStateStopped ) {
	}

	if( state == MPMoviePlaybackStatePlaying ) {
        [self videoStalledStopTimer];
	}
	if( state == MPMoviePlaybackStatePaused ) {
	}

	if( state == MPMoviePlaybackStateInterrupted ) {

        [self videoStalledStartTimer];

    }
	if( state == MPMoviePlaybackStateSeekingForward ) {
	} 
	if( state == MPMoviePlaybackStateSeekingBackward ) {
	}

}

- (void)playerPlayBackDidFinish:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
	NSError *error = [userInfo objectForKey:@"error"];
    NSInteger reasonForFinish = [[userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];

    if (error) {
        switch (reasonForFinish) {
            case MPMovieFinishReasonPlaybackError:
                break;
        }

        videoVideoFailedToLoad = YES;

    } else {
        switch (reasonForFinish) {
            case MPMovieFinishReasonPlaybackEnded:
                if(!videoWasSkipped){
                    [self advertActionTrackingEvent:@"complete"];
                    [self showOnVideoEndButtons];
                }
                break;
            case MPMovieFinishReasonUserExited:
                [self videoStopAdvert];
                break;
        }

    }

}

#pragma mark - UIWebView Delegates

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

    if (webView == self.interstitialWebView) {
        self.browserBackButton.enabled = webView.canGoBack;
        self.browserForwardButton.enabled = webView.canGoForward;
    }

}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {

        NSURL *theUrl = [request URL];

        NSString *requestString = [theUrl absoluteString];

        NSString *prefix = [requestString substringToIndex:5];

        if ([prefix isEqualToString:@"mfox:"]) {

            NSString *actionString = [requestString substringFromIndex:5];
            if ([actionString isEqualToString:@"playvideo"] && self.videoPlayer) {
                [self checkAndCancelAutoClose];

               [self.mobFoxVideoPlayerViewController.view addSubview:self.videoPlayer.view];
               videoViewController = [self firstAvailableUIViewController];
               videoViewController.wantsFullScreenLayout = YES;

               [videoViewController presentModalViewController:self.mobFoxVideoPlayerViewController animated:NO];
               [self advertShow:MobFoxAdTypeVideo viewToShow:self.mobFoxVideoPlayerViewController.view];

                return NO;
            }
            if ([actionString isEqualToString:@"skip"] && self.videoPlayer) {

                [self videoSkipAction:nil];

                return NO;
            }
            if ([actionString isEqualToString:@"replayvideo"]) {

                if (self.videoPlayer) {
                    [self videoReplayButtonAction:nil];
                }

                if(self.interstitialWebView) {
                    [self browserReloadButtonAction:nil];
                }

                return NO;
            }
            actionString = [requestString substringToIndex:14];
            if([actionString isEqualToString:@"mfox:external:"]) {

                [self checkAndCancelAutoClose];

                actionString = [requestString substringFromIndex:14];

                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionString]];
            }

            return NO;
        }

    }
    if (webView == self.interstitialWebView) {

        if(navigationType != UIWebViewNavigationTypeOther && navigationType != UIWebViewNavigationTypeReload && navigationType != UIWebViewNavigationTypeBackForward) {
            [self checkAndCancelAutoClose];
        }
        self.browserBackButton.enabled = webView.canGoBack;
        self.browserForwardButton.enabled = webView.canGoForward;

        return YES;

    }
    if (webView == self.videoHTMLOverlayWebView) {

        if (navigationType == UIWebViewNavigationTypeLinkClicked) {

            viewController = [self firstAvailableUIViewController];

            NSURL *theUrl = [request URL];

            NSString *requestString = [theUrl absoluteString];

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestString]];

            return NO;

        }

        return YES;
    }

    return YES;
}

#pragma mark - Modal Web View Display & Dismissal

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{

    if(!_browser)
        return;
    if (self.videoPlayer.playbackState == MPMoviePlaybackStatePlaying ) {
        videoWasPlaying = YES;
        [self videoPause];
    } else {
        videoWasPlaying = NO;
    }

    [rootViewController presentModalViewController:_browser animated:YES];

}

- (void)mobfoxAdBrowserControllerDidDismiss:(MobFoxAdBrowserViewController *)mobfoxAdBrowserController
{
	[mobfoxAdBrowserController dismissModalViewControllerAnimated:YES];

    if (self.videoPlayer.playbackState == MPMoviePlaybackStatePaused && videoWasPlaying) {
        [self videoUnPause];
    }

    _browser = nil;

    mobfoxAdBrowserController.webView = nil;
    mobfoxAdBrowserController = nil;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];;
    [self updateAllFrames:interfaceOrientation];
}

#pragma mark - UIGestureRecognizer & UIWebView & Tap Detecting Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}


- (void)handleOverlayClick:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded)     {
        
        [self checkAndCancelAutoClose];
        if(_overlayClickThrough) {
            if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWasClicked:)])
            {
                [delegate mobfoxVideoInterstitialViewWasClicked:self];
            }
            [self advertActionTrackingEvent:@"overlayClick"];
            NSString *escapedDataString = [_overlayClickThrough stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *clickUrl = [NSURL URLWithString:escapedDataString];
            [self tapThrough:YES tapThroughURL:clickUrl];
        }
    }
}


- (void)handleVideoClick:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded)     {

        if(_videoClickThrough) {
            [self advertActionTrackingEvent:@"videoClick"];
            if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWasClicked:)])
            {
                [delegate mobfoxVideoInterstitialViewWasClicked:self];
            }
            NSString *escapedDataString = [_videoClickThrough stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *clickUrl = [NSURL URLWithString:escapedDataString];
            [self tapThrough:YES tapThroughURL:clickUrl];
            
            [self videoShowSkipButton];
        }
    }
    
}


#pragma mark
#pragma mark Status Bar Handling

- (void)hideStatusBar
{
    UIApplication *app = [UIApplication sharedApplication];
    if(!app.statusBarHidden) {
        statusBarWasVisible = YES;
    } else {
        statusBarWasVisible = NO;
    }
    
    if((self.mobFoxVideoPlayerViewController && !self.interstitialHoldingView) || self.mobFoxInterstitialPlayerViewController) {
        return;
    }
    
	if (!app.statusBarHidden)
	{

        [app setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
		[app setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];


        CGRect frame = self.view.superview.frame;
        if([UIApplication sharedApplication].statusBarHidden ) {

            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

            if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {

                if (interfaceOrientation == UIInterfaceOrientationPortrait ) {
                    frame.origin.y -= statusBarHeight;
                } else {
                    frame.origin.y = 0;
                }
                frame.size.height += statusBarHeight;
            } else {

                if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
                    frame.origin.x -= statusBarHeight;
                } else {
                    frame.origin.x = 0;
                }
                frame.size.width += statusBarHeight;
            }

        }
        self.view.superview.frame = frame;

	}

}

- (void)showStatusBarIfNecessary
{
	if (statusBarWasVisible)
	{
		UIApplication *app = [UIApplication sharedApplication];

        [app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[app setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];

        CGRect frame = self.view.superview.frame;
        if(![UIApplication sharedApplication].statusBarHidden ) {

            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
                if (interfaceOrientation == UIInterfaceOrientationPortrait ) {
                    frame.origin.y += statusBarHeight;
                } else {
                    frame.origin.y = 0;
                }

                frame.size.height -= statusBarHeight;
            } else {
                if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
                    frame.origin.x += statusBarHeight;
                } else {
                    frame.origin.x = 0;
                }

                frame.size.width -= statusBarHeight;

            }
        }
        self.view.superview.frame = frame;

	}
}

#pragma mark
#pragma mark Notifications

- (void)advertAddNotificationObservers:(MobFoxAdGroupType)adGroup {

    if (adGroup == MobFoxAdGroupVideo) {

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(playerLoadStateDidChange:) 
                                                     name:MPMoviePlayerLoadStateDidChangeNotification 
                                                   object:self.videoPlayer];

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(playerPlayBackStateDidChange:) 
                                                     name:MPMoviePlayerLoadStateDidChangeNotification 
                                                   object:self.videoPlayer];

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(playerPlayBackDidFinish:) 
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:self.videoPlayer];
    }

    if (adGroup == MobFoxAdGroupInterstitial) {
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) 
                                                         name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)advertRemoveNotificationObservers:(MobFoxAdGroupType)adGroup {

    if (adGroup == MobFoxAdGroupVideo) {
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:MPMoviePlayerLoadStateDidChangeNotification 
                                                      object:nil];

        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:MPMoviePlayerPlaybackStateDidChangeNotification 
                                                      object:nil];

        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:MPMoviePlayerPlaybackDidFinishNotification 
                                                      object:nil];

    }
    if (adGroup == MobFoxAdGroupInterstitial) {
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:UIDeviceOrientationDidChangeNotification 
                                                        object:nil];
}

- (void) appDidBecomeActive:(NSNotification *)notification
{
    if (self.videoPlayer) {

        [self advertAddNotificationObservers:MobFoxAdGroupVideo];

        if (videoWasPlayingBeforeResign) {
            [self videoUnPause];

            videoWasPlayingBeforeResign = NO;
        }
    }

    if(self.interstitialWebView) {
        [self advertAddNotificationObservers:MobFoxAdGroupInterstitial];

    }

}

- (void) appWillResignActive:(NSNotification *)notification
{
    if (self.videoPlayer) {

        [self advertRemoveNotificationObservers:MobFoxAdGroupVideo];

        if (self.videoPlayer.playbackState == MPMoviePlaybackStatePlaying ) {
            videoWasPlayingBeforeResign = YES;
            [self videoPause];
        } else {
            videoWasPlayingBeforeResign = NO;
        }

    }

    if(self.interstitialWebView) {
        [self advertRemoveNotificationObservers:MobFoxAdGroupInterstitial];

    }

}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];;
    [self updateAllFrames:interfaceOrientation];
}

#pragma mark Banner View Delegate

-(void) mobfoxBannerViewActionWillPresent:(MobFoxBannerView *)banner {
    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWasClicked:)])
    {
        [delegate mobfoxVideoInterstitialViewWasClicked:self];
    }
}

-(void) mobfoxBannerViewActionWillLeaveApplication:(MobFoxBannerView *)banner {
    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewActionWillLeaveApplication:)])
    {
        [delegate mobfoxVideoInterstitialViewActionWillLeaveApplication:self];
    }
}

-(NSString*) publisherIdForMobFoxBannerView:(MobFoxBannerView *)banner {
    return [delegate publisherIdForMobFoxVideoInterstitialView:self];
}

@end
