//
//  IMNative+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "IMNative+Specs.h"
#import "IMNativeDelegate.h"

static NSString *gAdContent = nil;

@implementation IMNative (Specs)

- (void)loadAd
{
    [self.delegate nativeAdDidFinishLoading:self];
}

- (NSString *)content
{
    return gAdContent;
}

+ (void)mp_switchToNormalContent
{
    gAdContent = @"{\"title\":\"Ad Title String\",\"landing_url\":\"https://appstorelink.com\",\"screenshots\":{\"w\":568,\"ar\":1.77,\"url\":\"http://5018-presscdn-27-91.pagely.netdna-cdn.com/wp-content/themes/mopub/img/logo.png\",\"h\":320},\"icon\":{\"w\":568,\"ar\":1.77,\"url\":\"http://5018-presscdn-27-91.pagely.netdna-cdn.com/wp-content/themes/mopub/img/logo.png\",\"h\":320},\"cta\":\"cta text\",\"description\":\"Description body text\"}";
}

+ (void)mp_switchToBadMainImageURLContent
{
    gAdContent = @"{\"title\":\"Ad Title String\",\"landing_url\":\"https://appstorelink.com\",\"screenshots\":{\"w\":568,\"ar\":1.77,\"url\":\"||+++http://5018-presscdn-27-91.pagely.netdna-cdn.com/wp-content/themes/mopub/img/logo.png\",\"h\":320},\"icon\":{\"w\":568,\"ar\":1.77,\"url\":\"http://5018-presscdn-27-91.pagely.netdna-cdn.com/wp-content/themes/mopub/img/logo.png\",\"h\":320},\"cta\":\"cta text\",\"description\":\"Description body text\"}";
}

+ (void)mp_switchToBadIconImageURLContent
{
    gAdContent = @"{\"title\":\"Ad Title String\",\"landing_url\":\"https://appstorelink.com\",\"screenshots\":{\"w\":568,\"ar\":1.77,\"url\":\"http://5018-presscdn-27-91.pagely.netdna-cdn.com/wp-content/themes/mopub/img/logo.png\",\"h\":320},\"icon\":{\"w\":568,\"ar\":1.77,\"url\":\"||+++http://5018-presscdn-27-91.pagely.netdna-cdn.com/wp-content/themes/mopub/img/logo.png\",\"h\":320},\"cta\":\"cta text\",\"description\":\"Description body text\"}";
}

@end
