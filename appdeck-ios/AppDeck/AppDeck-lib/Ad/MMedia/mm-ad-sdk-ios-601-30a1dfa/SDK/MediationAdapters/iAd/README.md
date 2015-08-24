# iAd Mediation Adapter v1.0.0

This adapter mediates from the Millennial SDK 6.0 to iAd.

## Requirements

In order to use this mediation library you must link the following libraries:
* MMAdSDK.framework (v6.0.0)
* iAd.framework

## Integration

iAd uses non-standard placement sizes. If you are using iAd for anything other than inline portrait banners on a 3.5" or 4" (5S and prior) iPhone:
* Use the `MMInlineAdSizeFlexible` inline placement size.
* iAd uses a non-standard rectangle size of 320x250. Manually set this size for an inline rectangle placement, which can
still be filled with standard IAB-sized rectangles.

Refer to [Millennial Media Developer Documentation](http://docs.millennialmedia.com/) for the latest integration instructions.