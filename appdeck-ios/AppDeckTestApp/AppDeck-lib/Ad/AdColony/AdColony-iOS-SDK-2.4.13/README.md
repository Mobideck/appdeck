AdColony iOS SDK
==================================
Modified: 2014/10/30  
SDK Version: 2.4.13  

To Download:
----------------------------------
The simplest way to obtain the AdColony iOS SDK is to click the "Download ZIP" button located in the right-hand navigation pane of the Github repository page.

Contains:
----------------------------------
* AdColony.framework (iOS)
* Sample Apps
  * AdColonyAdvanced
  * AdColonyBasic
  * AdColonyV4VC
* W-9 Form.pdf

Getting Started with AdColony:
----------------------------------
New and returning users should review the [quick start guide](https://github.com/AdColony/AdColony-iOS-SDK/wiki), which contains detailed integration instructions.

2.4.13 Change Log:
----------------------------------
* Fully compatible with iOS 8.1
* Stylistic improvements to in-video engagement feature
* Fixed rare black screen on iPad Airs running iOS 8
* Fixed first-time install crash bug caused by Unity 4.5
* Miscellaneous bug fixes

2.4.12 Change Log:
----------------------------------
* Fixed memory leak caused by UIWebView on iOS 8
* Addressed multiple conflicts with Unity plugin
* Improved orientation functionality

2.4.10 Change Log:
----------------------------------
* Fully tested against the iOS 8 Gold Master
* Refinements and optimizations to AdColony Instant-Feed
* Bug fixes 

2.3.12 Change Log:
----------------------------------
* Initial public release of AdColony Instant-Feed
* New requirement: minimum Xcode Deployment Target of iOS 5.0
* New public class AdColonyNativeAdView which implements AdColony Instant-Feed
* AdColony class new method to request AdColonyNativeAdView objects
* Removed collection of OpenUDID, ODIN1, and MAC-SHA1 device identifiers on iOS 7+
* Removed collection of IDFV device identifier altogether
* Bug fixes and threading improvements

2.2.4 Change Log:
----------------------------------
* Added support for the 64-bit ARM architecture on new Apple devices
* The AdColony iOS SDK disables itself on iOS 4.3 (iOS 5.0+ is fully supported); the minimum Xcode Deployment Target remains iOS 4.3
* Bug fixes

2.2 Change Log:
----------------------------------
* AdColony 2.2 has been fully tested against the most recent iOS 7 betas and gold master seed
* AdColony is now packaged as a framework and its API is not backwards compatible with AdColony 2.0 integrations
* AdColony relies on additional frameworks and libraries; see the [quick start guide](https://github.com/AdColony/AdColony-iOS-SDK/wiki) for details. 
* The AdColony class has had methods removed and renamed for consistency
* The AdColonyDelegate protocol has had methods removed and renamed; its use is no longer mandatory
* The AdColonyTakeoverAdDelegate protocol has been renamed to AdColonyAdDelegate; it has had methods removed and renamed
* Improved detail and transparency of information regarding ad availability
* Various user experience improvements during ad display
* Increased developer control over network usage; improved efficiency and reliability
* Added console log messages to indicate when the SDK is out of date
* Bug fixes

2.0.1.33 Change Log:
----------------------------------
* Removed all usage of Apple's UDID in accordance with Apple policy

2.0 Change Log:
----------------------------------
* Support for Xcode 4.5, iOS 6.0, iPhone 5, and new "Limit Ad Tracking" setting
* Removed support for armv6 architecture devices
* Requires Automatic Reference Counting (ARC) for AdColony library (or whole project)
* Numerous bug fixes, stability improvements and performance gains
* Built-in support for multiple video views per V4VC reward
* Can collect per-user metadata that unlocks higher-value ads
* New sample applications
* Simplified interface for apps that need to cancel an ad in progress
* Simplified interface for apps that need custom user IDs for server-side V4VC transactions
* Improved log messages for easier debugging


Sample Applications:
----------------------------------
Included are three sample apps to use as examples and for help on AdColony integration. The basic app allows users to launch an ad, demonstrating simple usage of AdColony. The currency app demonstrates how to implement videos-for-virtual currency (V4VC) to enable users to watch videos in return for in-app virtual currency rewards (with currency balances stored client-side). The advanced app demonstrates advanced topics such as multiple zones and playing ads in apps with audio and music. 


Legal Requirements:
----------------------------------
By downloading the AdColony SDK, you are granted a limited, non-commercial license to use and review the SDK solely for evaluation purposes.  If you wish to integrate the SDK into any commercial applications, you must register an account with [AdColony](https://clients.adcolony.com/signup) and accept the terms and conditions on the AdColony website.

Note that U.S. based companies will need to complete the W-9 form and send it to us before publisher payments can be issued.


Contact Us:
----------------------------------
For more information, please visit AdColony.com. For questions or assistance, please email us at support@adcolony.com.

