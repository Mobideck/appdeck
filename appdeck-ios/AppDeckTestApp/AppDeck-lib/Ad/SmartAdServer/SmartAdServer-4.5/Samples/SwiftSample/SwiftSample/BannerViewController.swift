//
//  BannerViewController.swift
//  SwiftSample
//
//  Created by Loïc GIRON DIT METAZ on 22/07/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//


// The purpose of this sample is to display a simple image banner.
// This banner should be clickable and will be inserted in a layout defined in the application's storyboard (see Main.storyboard).
class BannerViewController: UIViewController, SASAdViewDelegate {
	
	var banner: SASBannerView? // Instance of the banner (marked as optional since it is created after the initialization of the controller)
	var statusBarHidden = false
	
	// MARK: - View controller lifecycle
	
	deinit {
		// The banner is automatically released by ARC but the delegate should be set to nil to prevent crashes during fast navigation in the application.
		// This can be made in the deinitializer which will be called automatically by ARC when the controller is released.
		banner?.delegate = nil
		
		NSLog("BannerViewController has been deallocated");
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.edgesForExtendedLayout = UIRectEdge.None;
		createBanner()
		createReloadButton()
	}
	
	func createReloadButton() {
		let reloadButton = UIBarButtonItem(title: "Reload", style: .Bordered, target: self, action: "reload")
		navigationItem.rightBarButtonItem = reloadButton
	}
	
	func reload() {
		removeBanner()
		createBanner()
	}
	
	func createBanner() {
		// The instance of the banner is created with a default frame and an appropriate loader.
		banner = SASBannerView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(view.frame), height: 53), loader: .ActivityIndicatorStyleWhite)
		
		if let actualBanner = banner {
			// Setting the delegate: please note that the delegate must be a view controller since it will be used to display the post click modal.
			actualBanner.delegate = self
			
			// Loading the ad (using IDs from the Constants class).
			actualBanner.loadFormatId(Constants.bannerFormatID(), pageId: Constants.bannerPageID(), master: true, target: nil)
			
			// Adding the ad view to the actual view of the controller.
			view.addSubview(actualBanner)
			
			// Since this sample is not defining any autolayout constraints but instead use frame and autoresizing masks, this informations must be
			// translated into constraints.
			// Please note that if you deactivate autoresizing translation (and you create your constraints yourself) on the ad view, it will prevent
			// creatives that resize/reposition the view to work (like toaster or resize banners).
			actualBanner.setTranslatesAutoresizingMaskIntoConstraints(true)
		}
	}
	
	func removeBanner() {
		if let actualBanner = banner {
			// Do not forget to set the delegate to nil every time you deallocate an ad view.
			actualBanner.delegate = nil
			actualBanner.removeFromSuperview()
		}
	}
	
	override func prefersStatusBarHidden() -> Bool {
		let defaultStatusBarStatus = super.prefersStatusBarHidden()
		return statusBarHidden || defaultStatusBarStatus
	}
	
	// MARK: - SASAdViewDelegate
	
	func adViewDidLoad(adView: SASAdView!)  {
		NSLog("Banner has been loaded")
	}
	
	func adView(adView: SASAdView!, didFailToLoadWithError error: NSError!) {
		NSLog("Banner has failed to load with error: \(error.description)")
		removeBanner()
	}
	
	func adViewWillExpand(adView: SASAdView!) {
		NSLog("Banner will expand")
		
		statusBarHidden = true;
		setNeedsStatusBarAppearanceUpdate()
	}
	
	func adView(adView: SASAdView!, didCloseExpandWithFrame frame: CGRect) {
		NSLog("Banner did close expand")
		
		statusBarHidden = false;
		setNeedsStatusBarAppearanceUpdate()
	}

}
