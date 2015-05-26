//
//  MobFoxNativeTrackingView.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 26.05.2014.
//
//

#import "MobFoxNativeTrackingView.h"

@interface MobFoxNativeTrackingView() <UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSString* userAgent;
@property (nonatomic) BOOL wasShown;
@end


@implementation MobFoxNativeTrackingView


- (id)initWithFrame:(CGRect)frame andUserAgent:(NSString*)userAgent
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    self.userAgent = userAgent;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.delegate = self;
    
    [self addGestureRecognizer:tap];
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if(!self.wasShown) {
        self.wasShown = YES;
        [self performSelectorOnMainThread:@selector(reportImpression) withObject:nil waitUntilDone:YES];
        [nativeAd handleImpression];
        
        NSMutableArray* impressionTrackers = [[NSMutableArray alloc]init];
        for (MFTracker* t in nativeAd.trackers) {
            if([t.type isEqualToString:@"impression"]) {
                [impressionTrackers addObject:t.url];
            }
        }
        
        for(NSString *impressionUrl in impressionTrackers) {
            [self makeTrackingRequest:impressionUrl];
        }
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)reportImpression
{
	if ([delegate respondsToSelector:@selector(nativeAdWasShown)])
	{
		[delegate nativeAdWasShown];
	}
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    [self performSelectorOnMainThread:@selector(reportClick) withObject:nil waitUntilDone:YES];
    [nativeAd handleClick];
    
    if(nativeAd.clickUrl && nativeAd.clickUrl.length > 0) {
        NSURL *clickURL = [NSURL URLWithString:nativeAd.clickUrl];
        [[UIApplication sharedApplication]openURL:clickURL];
    }
}

- (void)makeTrackingRequest:(NSString*) impressionUrl {
    NSURL* url = [NSURL URLWithString:impressionUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod: @"GET"];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:nil];
}

-(void)removeFromSuperview {
    self.nativeAd = nil;
    self.delegate = nil;

    [super removeFromSuperview];
}

- (void)reportClick
{
	if ([delegate respondsToSelector:@selector(nativeAdWasClicked)])
	{
		[delegate nativeAdWasClicked];
	}
}

- (void)dealloc
{
    self.nativeAd = nil;
    self.delegate = nil;
    self.userAgent = nil;
}

@synthesize nativeAd;
@synthesize delegate;

@end
