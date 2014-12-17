//
//  Constants.swift
//  SwiftSample
//
//  Created by Loïc GIRON DIT METAZ on 22/07/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//


// IDs used by the Smart AdServer SDK to retrive the ads.
class Constants {
	
	class func siteID() -> Int { return 28298 }
	class func baseURL() -> String { return "http://mobile.smartadserver.com" }
	
	class func bannerFormatID() -> Int { return 12161 }
	class func interstitialFormatID() -> Int { return 12167 }
	
	class func bannerPageID() -> String { return "188761" }
	class func toasterPageID() -> String { return "188762" }
	class func interstitialPageID() -> String { return "188763" }
	class func interstitialDismissalAnimationPageID() -> String { return "188763" }
	class func prefetchInterstitialPageID() -> String { return "297754" }
	
}
