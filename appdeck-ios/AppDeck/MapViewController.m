//
//  MapViewController.m
//  AppDeck
//
//  Created by hanine ben saad on 18/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <MapViewPlus/MapViewPlus-Swift.h>

@interface MapViewController (){
    MapViewPlus*mapView;
}

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    mapView = [[MapViewPlus alloc] initWithFrame:self.view.frame];
    [self.view addSubview:mapView];
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
    
    // Do any additional setup after loading the view.
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [locationManager stopUpdatingLocation];
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
//    NSMutableArray*annotation=[NSMutableArray array];
//    [annotation addObject:[AnnotationPlus anno]];
 //   [mapView setupWithAnnotations:@[[AnnotationPlus ]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
