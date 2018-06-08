//
//  MapViewController.h
//  AppDeck
//
//  Created by hanine ben saad on 18/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoaderChildViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : LoaderChildViewController<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) AppDeckApiCall *call;
@property (nonatomic, weak) LoaderChildViewController* child;
//-(void)getCurrentLocation;

@end
