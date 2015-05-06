//
//  MenuItem.m
//  ObjCSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "MenuItem.h"


@implementation MenuItem

- (id)initWithTitle:(NSString *)title {
	self = [super init];
	
	if (self) {
		_title = title;
	}
	return self;
}

@end
