//
//  AppDelegate.swift
//  SwiftSample
//
//  Created by Clémence Laurent on 11/07/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
		
		// The site ID and the base URL must be set before using the SDK, otherwise no ad will be retrieved.
		SASAdView.setSiteID(Constants.siteID(), baseURL: Constants.baseURL())
		
		// Enabling logging can be useful to get informations if ads are not displayed properly.
		// Don't forget to turn logging OFF before submitting to the App Store.
		SASAdView.setLoggingEnabled(true)
		
		// You can enable the test mode if you want the SDK to retrieve sample ads that always deliver instead
		// of your own ads. You will only receive a simple image banner or an interstitial depending on the type of
		// SASAdView you are using.
		// Don't forget to turn test mode OFF before submutting to the App Store.
		SASAdView.setTestModeEnabled(false)
		
		return true
	}
}

