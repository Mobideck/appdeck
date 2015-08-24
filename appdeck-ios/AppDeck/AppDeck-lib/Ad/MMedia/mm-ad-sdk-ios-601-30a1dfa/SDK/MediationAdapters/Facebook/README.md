# Facebook Mediation Adapter v1.0.0

This adapter mediates from the Millennial SDK 6.0 to Facebook native.

## Requirements

In order to use this mediation library you must link the following libraries:
* MMAdSDK.framework (v6.0.0)
* FBAudienceNetwork.framework (v4.4.0 FacebookSDKs-iOS-20150708)
* AdSupport.framework
* StoreKit.framework
* CoreMotion.framework

You must include the following headers, provided with the adapter:
* MMFacebookNative.h

## Integration

Refer to [Facebook iOS SDK documentation](https://developers.facebook.com/docs/ios) for the latest integration instructions, libraries, and information from Facebook on their SDK.

Facebook mediation is currently for native only. Your native placement must advertise that it supports the `MMNativeAdTypeFacebook` native type in order to receive ads from the Facebook network. For example, to receive ads from both the Millennial and Facebook networks:

```
#import <MMAdSDK/MMAdSDK.h>
#import "MMFacebookNative.h" // Declares the MMNativeAdTypeFacebook native ad type

...

MMNativeAd* nativeAd = [[MMNativeAd alloc] initWithPlacementId:@"<YOUR_PLACEMENT_ID>" supportedTypes:@[MMNativeAdTypeInline, MMNativeAdTypeFacebook]];
```

Refer to [Millennial Media Developer Documentation](http://docs.millennialmedia.com/) for the latest integration instructions.