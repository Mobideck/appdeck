//
//  ToasterViewController.swift
//  SwiftSample
//
//  Created by Loïc GIRON DIT METAZ on 22/07/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//


// The purpose of this sample is to display a simple image toaster.
// Displaying a toaster works the same way as a banner (and actually use a SASBannerView), except that more delegate methods are available.
// This toaster will be inserted in a layout defined in the application's storyboard (see Main.storyboard).
class ToasterViewController: UIViewController {
	
	var toaster: SASBannerView? // Instance of the toaster (marked as optional since it is created after the initialization of the controller)
	var statusBarHidden = false
	
	// MARK: - View controller lifecycle
	
	deinit {
		// The toaster is automatically released by ARC but the delegate should be set to nil to prevent crashes during fast navigation in the application.
		// This can be made in the deinitializer which will be called automatically by ARC when the controller is released.
		toaster?.delegate = nil
		
		NSLog("ToasterViewController has been deallocated");
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.edgesForExtendedLayout = UIRectEdge.None;
		createToaster()
		createReloadButton()
	}
	
	func createReloadButton() {
		let reloadButton = UIBarButtonItem(title: "Reload", style: .Bordered, target: self, action: "reload")
		navigationItem.rightBarButtonItem = reloadButton
	}
	
	func reload() {
		removeToaster()
		createToaster()
	}
	
	func createToaster() {
		// The instance of the toaster is created with a default frame and an appropriate loader.
		let bannerHeight: CGFloat = 53
		toaster = SASBannerView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(view.frame), height: bannerHeight), loader: .ActivityIndicatorStyleWhite)
		
		if let actualToaster = toaster {
			// Setting the delegate: please note that the delegate must be a view controller since it will be used to display the post click modal.
			actualToaster.delegate = self
			
			// Loading the ad (using IDs from the Constants class).
			actualToaster.loadFormatId(Constants.bannerFormatID(), pageId: Constants.toasterPageID(), master: true, target: nil)
			
			// Adding the ad view to the actual view of the controller.
			view.addSubview(actualToaster)
			
			// Since this sample is not defining any autolayout constraints but instead use frame and autoresizing masks, this informations must be
			// translated into constraints.
			// Please note that if you deactivate autoresizing translation (and you create your constraints yourself) on the ad view, it will prevent
			// creatives that resize/reposition the view to work (like toaster or resize banners).
			actualToaster.setTranslatesAutoresizingMaskIntoConstraints(true)
		}
	}
	
	func removeToaster() {
		if let actualToaster = toaster {
			// Do not forget to set the delegate to nil every time you deallocate an ad view.
			actualToaster.delegate = nil
			actualToaster.removeFromSuperview()
		}
	}
	
	override func prefersStatusBarHidden() -> Bool {
		let defaultStatusBarStatus = super.prefersStatusBarHidden()
		return statusBarHidden || defaultStatusBarStatus
	}
	
	// MARK: - SASAdViewDelegate
	
	func adViewDidLoad(adView: SASAdView!) {
		NSLog("Toaster has been loaded")
	}
	
	func adView(adView: SASAdView!, didFailToLoadWithError error: NSError!) {
		NSLog("Toaster has failed to load with error: \(error.description)")
		removeToaster()
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
