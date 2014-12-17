//
//  PrefetchInterstitialViewController.swift
//  SwiftSample
//
//  Created by Loïc GIRON DIT METAZ on 22/07/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//


// The purpose of this sample is to display a simple prefeteched image interstitial.
// The integration of a prefetched interstitial is quite similar to the integration of a regular interstitial, only the load ad method is different.
// This interstitial will be inserted in a layout defined in the application's storyboard (see Main.storyboard).
//
// Note: the SDK can only handle one prefetch placement per application.
class PrefetchInterstitialViewController: UIViewController {
	
	var interstitial: SASInterstitialView? // Instance of the interstitial (marked as optional since it is created after the initialization of the controller)
	var statusBarHidden = false
	
	// MARK: - View controller lifecycle
	
	deinit {
		// The interstitial is automatically released by ARC but the delegate should be set to nil to prevent crashes during fast navigation in the application.
		// This can be made in the deinitializer which will be called automatically by ARC when the controller is released.
		interstitial?.delegate = nil
		
		NSLog("PrefetchInterstitialViewController has been deallocated");
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		createLoadButton()
	}
	
	func createLoadButton() {
		let loadButton = UIBarButtonItem(title: "Load", style: .Bordered, target: self, action: "load")
		navigationItem.rightBarButtonItem = loadButton
	}
	
	func load() {
		// Do not forget to set the delegate to nil every time you deallocate an ad view.
		interstitial?.delegate = nil
		
		createInterstitial()
	}
	
	func createInterstitial() {
		// The instance of the interstitial is created with a default frame and an appropriate loader.
		interstitial = SASInterstitialView(frame: CGRect(x: 0.0, y: 0.0, width: CGRectGetWidth(view.frame), height: CGRectGetHeight(view.frame)), loader: .ActivityIndicatorStyleBlack)
		
		if let actualInterstitial = interstitial {
			// Setting the delegate: please note that the delegate must be a view controller since it will be used to display the post click modal.
			actualInterstitial.delegate = self
			
			// Loading the ad (using IDs from the Constants class).
			actualInterstitial.prefetchFormatId(Constants.interstitialFormatID(), pageId: Constants.prefetchInterstitialPageID(), master: true, target: nil)
			
			// Adding the ad view to the actual view of the controller.
			navigationController?.view.addSubview(actualInterstitial)
			
			// Since this sample is using autolayout, we deactivate autoresizing mask on the ad view.
			actualInterstitial.setTranslatesAutoresizingMaskIntoConstraints(false)
			
			// Then we add constraints so that the interstitial stays below the navigation bar for all sizes and orientations.
			let views: [NSObject : AnyObject] = ["v": actualInterstitial]
			navigationController?.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
			navigationController?.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[v]|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
		}
		
		statusBarHidden = true;
		setNeedsStatusBarAppearanceUpdate()
	}
	
	override func prefersStatusBarHidden() -> Bool {
		let defaultStatusBarStatus = super.prefersStatusBarHidden()
		return statusBarHidden || defaultStatusBarStatus
	}
	
	// MARK: - SASAdViewDelegate
	
	func adViewDidLoad(adView: SASAdView!)  {
		NSLog("Interstitial has been loaded")
	}
	
	func adView(adView: SASAdView!, didFailToLoadWithError error: NSError!) {
		NSLog("Interstitial has failed to load with error: \(error.description)")
	}
	
	func adViewDidDisappear(adView: SASAdView!) {
		NSLog("Interstitial has disappeared")
		
		statusBarHidden = false
		setNeedsStatusBarAppearanceUpdate()
	}
}
