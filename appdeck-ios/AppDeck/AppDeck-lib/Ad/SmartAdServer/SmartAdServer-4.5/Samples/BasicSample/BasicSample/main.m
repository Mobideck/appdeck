//
//  main.m
//  Sample
//
//  Created by Julien Stoeffler on 07/07/11.
//  Copyright 2011 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SampleAppDelegate.h"


int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([SampleAppDelegate class]));
    [pool release];
    return retVal;
}
