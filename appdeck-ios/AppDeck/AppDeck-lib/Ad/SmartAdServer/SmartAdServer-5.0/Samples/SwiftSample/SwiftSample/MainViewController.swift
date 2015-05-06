//
//  ViewController.swift
//  SwiftSample
//
//  Created by Clémence Laurent on 11/07/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//


// This view controller acts as a main menu and redirects the user on the various sample view controllers.
// Most of the UI behavior is now in the storyboard (Main.storyboard).
class MainViewController: UITableViewController, SASAdViewDelegate {
	
	var items: Array<MenuItem> = Array()
	
	// MARK: - View controller lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		initializeItems()
	}
	
	// MARK: - Items initialization
	
	func initializeItems() {
		addItemInItemsArray("Banner", segueIdentifier: "BannerViewControllerSegue")
		addItemInItemsArray("Toaster", segueIdentifier: "ToasterViewControllerSegue")
		addItemInItemsArray("Interstitial", segueIdentifier: "InterstitialViewControllerSegue")
		addItemInItemsArray("Interstitial dismiss animation", segueIdentifier: "InterstitialDismissalAnimationViewControllerSegue")
		addItemInItemsArray("Prefetch interstitial", segueIdentifier: "PrefetchInterstitialViewControllerSegue")
		tableView.reloadData()
	}
	
	func addItemInItemsArray(title: String, segueIdentifier:String) -> MenuItem {
		let item = MenuItem(title: title, segueIdentifier: segueIdentifier)
		items.append(item)
		return item
	}
	
	// MARK: - Table view delegate & data source
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
		return items.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("sampleCell") as UITableViewCell
		cell.textLabel?.text? = items[indexPath.row].title
		return cell
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
		return 1
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
		return "Choose a sample:";
	}
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String {
		return "\nThis sample demonstrates how to implement the Smart AdServer SDK in Swift application."
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier(items[indexPath.row].segueIdentifier, sender: nil)
	}
	
}
