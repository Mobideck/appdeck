//
//  MenuItem.h
//  ObjCSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MenuItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIViewController *controller;

- (id)initWithTitle:(NSString *)title;

@end
