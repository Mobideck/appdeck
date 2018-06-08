//
//  MapViewController.m
//  AppDeck
//
//  Created by hanine ben saad on 18/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
//#import <MapViewPlus/MapViewPlus-Swift.h>
#import "DXAnnotationView.h"
#import "DXAnnotationSettings.h"
#import "AppURLCache.h"
#import "myView.h"
@interface DXAnnotation : NSObject <MKAnnotation>

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, assign) BOOL isMyLocation;
@property(nonatomic, retain) NSDictionary*pointsDict;
@property(nonatomic, retain) NSString*myAddress;

@end


@implementation DXAnnotation

@end


@interface MapViewController () <MKMapViewDelegate>{
    MKMapView*mapView;
    NSMutableArray*annotations;
}

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:mapView];
    mapView.delegate=self;
    
    
    annotations=[[NSMutableArray alloc] init];
    for (NSDictionary*dict in [_call.param objectForKey:@"points"]) {
        DXAnnotation *annotation = [DXAnnotation new];
        annotation.coordinate = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lon"] doubleValue]);
        annotation.isMyLocation=false;
        annotation.pointsDict=dict;
        [annotations addObject:annotation];
        [mapView addAnnotation:annotation];
       
    }
    
    [mapView showAnnotations:annotations animated:true];
    

    if ([[_call.param objectForKey:@"show_location"] boolValue]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            [locationManager requestWhenInUseAuthorization];
        
        [locationManager startUpdatingLocation];
        
    }
   
    // Do any additional setup after loading the view.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  
    
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    
    [locationManager stopUpdatingLocation];
    locationManager=nil;
    
    DXAnnotation *annotation1 = [DXAnnotation new];
    annotation1.isMyLocation=true;
   
    annotation1.coordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [mapView addAnnotation:annotation1];
    [annotations addObject:annotation1];
    [mapView showAnnotations:annotations animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[DXAnnotation class]]) {
        
       __block UIImageView *pinView = nil;
        
        myView *calloutView = nil;
        
        DXAnnotationView *annotationView = (DXAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([DXAnnotationView class])];
       
        if (!annotationView) {
            
            if (((DXAnnotation*)annotation).isMyLocation)
                pinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me"]];
            else
                pinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point"]];
            
            calloutView = [[[NSBundle mainBundle] loadNibNamed:@"myView" owner:self options:nil] firstObject];
            calloutView.frame=CGRectMake(0, 0, 150, 50);
            
            if (((DXAnnotation*)annotation).isMyLocation) {
                calloutView.title.text=@"Me";
                
                CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
                [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude]
                               completionHandler:^(NSArray *placemarks, NSError *error) {
                                   for (CLPlacemark *placemark in placemarks) {
                                       
                                       NSLog(@"%@",[placemark locality]);
                                       
                                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                                       
                                       NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                                       NSLog(@"placemark.country %@",placemark.country);
                                       NSLog(@"placemark.postalCode %@",placemark.postalCode);
                                       NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
                                       NSLog(@"placemark.locality %@",placemark.locality);
                                       NSLog(@"placemark.subLocality %@",placemark.subLocality);
                                       NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
                                       NSLog(@"placemark.subThoroughfare %@",placemark.name);
                                       
                                       calloutView.address.text=placemark.name;
                                   }
                               }];
                
               
            }else{
                
                calloutView.title.text=[((DXAnnotation*)annotation).pointsDict objectForKey:@"title"];
                calloutView.address.text=[((DXAnnotation*)annotation).pointsDict objectForKey:@"address"];
                [calloutView downloadImage:[((DXAnnotation*)annotation).pointsDict objectForKey:@"image"] inChild:self.child];
            }
            
                annotationView = [[DXAnnotationView alloc] initWithAnnotation:annotation
                                                              reuseIdentifier:NSStringFromClass([DXAnnotationView class])
                                                                      pinView:pinView
                                                                  calloutView:calloutView
                                                                     settings:[DXAnnotationSettings defaultSettings]];
     
        }else {
            
            pinView = (UIImageView *)annotationView.pinView;
            pinView.image = [UIImage imageNamed:@"point"];
        }
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[DXAnnotationView class]]) {
        [((DXAnnotationView *)view)hideCalloutView];
        view.layer.zPosition = -1;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[DXAnnotationView class]]) {
        [((DXAnnotationView *)view)showCalloutView];
        view.layer.zPosition = 0;
    }
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
