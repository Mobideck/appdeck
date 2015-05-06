//
//  InterstitialDismissalAnimationViewController.swift
//  SwiftSample
//
//  Created by Loïc GIRON DIT METAZ on 22/07/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//


// The purpose of this sample is to display a simple image interstitial that will be dismissed with a custom animation.
// This interstitial should be clickable and will be inserted in a layout defined in the application's storyboard (see Main.storyboard).
class InterstitialDismissalAnimationViewController: UIViewController, SASAdViewDelegate {
	
	var interstitial: SASInterstitialView? // Instance of the interstitial (marked as optional since it is created after the initialization of the controller)
	
	// MARK: - View controller lifecycle
	
	deinit {
		// The interstitial is automatically released by ARC but the delegate and the modalParentViewController should be set to nil to prevent crashes during fast navigation in the application.
		// This can be made in the deinitializer which will be called automatically by ARC when the controller is released.
		interstitial?.delegate = nil
        interstitial?.modalParentViewController = nil
		
		NSLog("InterstitialDismissalAnimationViewController has been deallocated");
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
		// Do not forget to set the delegate and the modalParentViewController to nil every time you deallocate an ad view.
		interstitial?.delegate = nil
        interstitial?.modalParentViewController = nil
		
		createInterstitial()
	}
	
	func createInterstitial() {
		// The instance of the interstitial is created with a default frame and an appropriate loader.
		interstitial = SASInterstitialView(frame: CGRect(x: CGRectGetMinX(view.frame), y: CGRectGetMinY(view.frame), width: CGRectGetWidth(view.frame), height:CGRectGetHeight(view.frame)), loader: .ActivityIndicatorStyleBlack)
		
		if let actualInterstitial = interstitial {
			// Setting the delegate.
            actualInterstitial.delegate = self
            
            // Setting the modal parent view controller.
            actualInterstitial.modalParentViewController = self
			
			// Loading the ad (using IDs from the Constants class).
			actualInterstitial.loadFormatId(Constants.interstitialFormatID(), pageId: Constants.interstitialDismissalAnimationPageID(), master: true, target: nil)
			
			// Adding the ad view to the actual view of the controller.
			navigationController?.view.addSubview(actualInterstitial)
			
			// In Swift, the dismissalAnimation is defined as a closure.
			actualInterstitial.dismissalAnimations = { (adView: SASAdView!) in
				// In this sample, the interstitial is swiped to the top of the screen and dimmed (using alpha property) during closing.
				adView.frame = CGRect(x: CGRectGetMinX(adView.frame), y: -CGRectGetHeight(adView.frame), width: CGRectGetWidth(adView.frame), height: CGRectGetHeight(adView.frame));
				adView.alpha = 0;
			}
			
			// Since this sample is using autolayout, we deactivate the autoresizing mask on the ad view.
			actualInterstitial.setTranslatesAutoresizingMaskIntoConstraints(false)
			
			// Then we add constraints so that the interstitial stays below the navigation bar for all sizes and orientations.
			let views: [NSObject : AnyObject] = ["v": actualInterstitial]
			navigationController?.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
			navigationController?.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[v]|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
		}
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
	}
}
