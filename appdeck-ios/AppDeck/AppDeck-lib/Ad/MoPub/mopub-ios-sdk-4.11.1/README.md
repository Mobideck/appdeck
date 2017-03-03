# MoPub iOS SDK

Thanks for taking a look at MoPub! We take pride in having an easy-to-use, flexible monetization solution that works across multiple platforms.

Sign up for an account at [http://app.mopub.com/](http://app.mopub.com/).

## Need Help?

You can find integration documentation on our [wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started) and additional help documentation on our [developer help site](http://dev.twitter.com/mopub).

To file an issue with our team visit the [MoPub Forum](https://twittercommunity.com/c/fabric/mopub) or email [support@mopub.com](mailto:support@mopub.com).

**Please Note: We no longer accept GitHub Issues**

## Download

The MoPub SDK is distributed as source code that you can include in your application.  MoPub provides two prepackaged archives of source code:

- **[MoPub Base SDK.zip](http://bit.ly/2bH8ObO)**

  Includes everything you need to serve HTML, MRAID, and Native MoPub advertisements.  Third party ad networks are not included.
  
- **[MoPub Base SDK Excluding Native.zip](http://bit.ly/2bCCgRw)**

  Includes everything you need to serve HTML and MRAID advertisements.  Third party ad networks and Native MoPub advertisements are not included.

The current version of the SDK is 4.11.1

## Integrate

Integration instructions are available on the [wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started).

More detailed class documentation is available in the repo under the `ClassDocumentation` folder.  This can be viewed [online too](http://htmlpreview.github.com/?https://github.com/mopub/mopub-ios-sdk/blob/master/ClassDocumentation/index.html).

## New in this Version

Please view the [changelog](https://github.com/mopub/mopub-ios-sdk/blob/master/CHANGELOG.md) for details.

- **App Transport Security Updates**
	- Checks for "NSAllowsArbitraryLoadsInMedia" were changed to "NSAllowsArbitraryLoadsForMedia", per updated Apple documentation
	- Resolves issue in which explicitly using NSAllowsArbitraryLoadsForMedia or NSAllowsArbitraryLoadsInWebContent causes HTTP clickthroughs not to resolve on iOS 10.1 or higher

See the [Getting Started Guide](https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started#app-transport-security-settings) for instructions on setting up ATS in your app.  


### IMPORTANT 4.0 UPGRADE INSTRUCTIONS

See our [upgrade document](https://github.com/mopub/mopub-ios-sdk/wiki/Upgrading-Native-Ads-Integration-to-4.0) for complete native ads integration migration instructions.


## Requirements

iOS 7.0 and up

## License

We have launched a new license as of version 3.2.0. To view the full license, visit [http://www.mopub.com/legal/sdk-license-agreement/](http://www.mopub.com/legal/sdk-license-agreement/)
