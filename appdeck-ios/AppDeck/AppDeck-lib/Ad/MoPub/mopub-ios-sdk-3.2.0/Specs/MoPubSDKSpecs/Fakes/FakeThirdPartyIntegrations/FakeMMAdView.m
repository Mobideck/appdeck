//
//  FakeMMAdView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMMAdView.h"

@implementation FakeMMAdView

- (MMAdView *)masquerade
{
    return (MMAdView *)self;
}

- (void)getAdWithRequest:(MMRequest *)request onCompletion:(MMCompletionBlock)callback
{
    self.request = request;
    self.completionBlock = callback;
}

- (void)simulateLoadingAd
{
    self.completionBlock(YES,nil);
}

- (void)simulateFailingToLoad
{
    self.completionBlock(NO,nil);
}

- (NSDictionary *)userInfo
{
    return @{MillennialMediaAdObjectKey: self, MillennialMediaAdTypeKey: MillennialMediaAdTypeBanner, MillennialMediaAPIDKey: self.apid};
}

- (void)simulateUserTap
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWasTapped object:nil userInfo:self.userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalWillAppear object:nil userInfo:self.userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalDidAppear object:nil userInfo:self.userInfo];
}

- (void)simulateUserLeavingApplication:(BOOL)modalFirst
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWasTapped object:nil userInfo:self.userInfo];

    if (modalFirst) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalWillAppear object:nil userInfo:self.userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalDidAppear object:nil userInfo:self.userInfo];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWillTerminateApplication object:nil userInfo:self.userInfo];

    if (modalFirst) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalWillDismiss object:nil userInfo:self.userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalDidDismiss object:nil userInfo:self.userInfo];
    }
}

- (void)simulateUserEndingInteraction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalWillDismiss object:nil userInfo:self.userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalDidDismiss object:nil userInfo:self.userInfo];
}

@end
