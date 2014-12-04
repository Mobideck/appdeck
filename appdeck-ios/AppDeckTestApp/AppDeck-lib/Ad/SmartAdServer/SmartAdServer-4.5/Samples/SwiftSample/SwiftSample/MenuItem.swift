//
//  MenuItem.swift
//  SwiftSample
//
//  Created by Loïc GIRON DIT METAZ on 22/07/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//


// Represents an entry in the Main menu.
class MenuItem: NSObject {
	
	let title: String
	let segueIdentifier: String
	
	init(title: String, segueIdentifier: String) {
		self.title = title
		self.segueIdentifier = segueIdentifier
		super.init()
	}
	
}