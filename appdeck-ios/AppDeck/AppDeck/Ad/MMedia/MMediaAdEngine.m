//
//  MMediaAdEngine.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MMediaAdEngine.h"
#import "MMedia/MMSDK/MMSDK.h"
#import "MMediaBannerAdViewController.h"
#import "MMediaRectangleAdViewController.h"
#import "MMediaInterstitialAdViewController.h"
#import "AdManager.h"

@implementation MMediaAdEngine

- (id)initWithAdManager:(AdManager *)adManager andConfiguration:(NSDictionary *)config
{
    self = [super initWithAdManager:adManager andConfiguration:config];
    if (self) {
        // Custom initialization
        [MMSDK initialize]; //Initialize a Millennial Media session
        
        self.bannerAPID = @"140990";
        self.rectangleAPID = @"140991";
        self.InterstitialAPID = @"140995";
        /*
        //Create a location manager for passing location data for conversion tracking and ad requests
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager startUpdatingLocation];
         */
        // Notification will fire when an ad causes the application to terminate or enter the background
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminateFromAd:)
                                                     name:MillennialMediaAdWillTerminateApplication
                                                   object:nil];
        
        // Notification will fire when an ad is tapped.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(adWasTapped:)
                                                     name:MillennialMediaAdWasTapped
                                                   object:nil];
        
        // Notification will fire when an ad modal will appear.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(adModalWillAppear:)
                                                     name:MillennialMediaAdModalWillAppear
                                                   object:nil];
        
        // Notification will fire when an ad modal did appear.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(adModalDidAppear:)
                                                     name:MillennialMediaAdModalDidAppear
                                                   object:nil];
        
        // Notification will fire when an ad modal will dismiss.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(adModalWillDismiss:)
                                                     name:MillennialMediaAdModalWillDismiss
                                                   object:nil];
        
        // Notification will fire when an ad modal did dismiss.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(adModalDidDismiss:)
                                                     name:MillennialMediaAdModalDidDismiss
                                                   object:nil];
    }
    return self;
}

-(BannerAdViewController *)createBannerAd
{
    return [[MMediaBannerAdViewController alloc] initWithAdManager:self.adManager andEngine:self];
}

-(RectangleAdViewController *)createRectangleAd
{
    return [[MMediaRectangleAdViewController alloc] initWithAdManager:self.adManager andEngine:self];
}

-(InterstitialAdViewController *)createInterstitialAd
{
    return [[MMediaInterstitialAdViewController alloc] initWithAdManager:self.adManager andEngine:self];
}

#pragma mark - Meta Data

-(void)passMetadata:(MMRequest *)request
{
    // age
    if (self.adManager.yearOfBirth)
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setYear:self.adManager.yearOfBirth];
        if (self.adManager.monthOfBirth)
            [components setMonth:self.adManager.monthOfBirth];
        if (self.adManager.dayOfBirth)
            [components setDay:self.adManager.dayOfBirth];
        NSDate *birthdayDate = [calendar dateFromComponents:components];
        NSDate *todayDate = [NSDate date];
        int time = [todayDate timeIntervalSinceDate:birthdayDate];
        int allDays = (((time/60)/60)/24);
        int days = allDays%365;
        int years = (allDays-days)/365;
        
        request.age = [NSNumber numberWithInt:years];
    }
    
    // gender
    if (self.adManager.gender)
    {
        if (self.adManager.gender == AdManagerGenderMale)
            request.gender = MMGenderMale;
        else if (self.adManager.gender == AdManagerGenderFemale)
            request.gender = MMGenderFemale;
    }
    
    // Ethnicity
    
    
}

#pragma mark - Millennial Media Notification Methods

- (void)adWasTapped:(NSNotification *)notification {
    NSLog(@"AD WAS TAPPED");
    NSLog(@"TAPPED AD IS TYPE %@", [[notification userInfo] objectForKey:MillennialMediaAdTypeKey]);
    NSLog(@"TAPPED AD APID IS %@", [[notification userInfo] objectForKey:MillennialMediaAPIDKey]);
    NSLog(@"TAPPED AD IS OBJECT %@", [[notification userInfo] objectForKey:MillennialMediaAdObjectKey]);
    
    if ([[notification userInfo] objectForKey:MillennialMediaAdObjectKey] == nil) {
        NSLog(@"TAPPED AD IS THE _bannerAdView INSTANCE VARIABLE");
    }
}

- (void)applicationWillTerminateFromAd:(NSNotification *)notification {
    NSLog(@"AD WILL OPEN SAFARI");
    // No User Info is passed for this notification
}

- (void)adModalWillDismiss:(NSNotification *)notification {
    NSLog(@"AD MODAL WILL DISMISS");
    NSLog(@"AD IS TYPE %@", [[notification userInfo] objectForKey:MillennialMediaAdTypeKey]);
    NSLog(@"AD APID IS %@", [[notification userInfo] objectForKey:MillennialMediaAPIDKey]);
    NSLog(@"AD IS OBJECT %@", [[notification userInfo] objectForKey:MillennialMediaAdObjectKey]);
}

- (void)adModalDidDismiss:(NSNotification *)notification {
    NSLog(@"AD MODAL DID DISMISS");
    NSLog(@"AD IS TYPE %@", [[notification userInfo] objectForKey:MillennialMediaAdTypeKey]);
    NSLog(@"AD APID IS %@", [[notification userInfo] objectForKey:MillennialMediaAPIDKey]);
    NSLog(@"AD IS OBJECT %@", [[notification userInfo] objectForKey:MillennialMediaAdObjectKey]);
}

- (void)adModalWillAppear:(NSNotification *)notification {
    NSLog(@"AD MODAL WILL APPEAR");
    NSLog(@"AD IS TYPE %@", [[notification userInfo] objectForKey:MillennialMediaAdTypeKey]);
    NSLog(@"AD APID IS %@", [[notification userInfo] objectForKey:MillennialMediaAPIDKey]);
    NSLog(@"AD IS OBJECT %@", [[notification userInfo] objectForKey:MillennialMediaAdObjectKey]);
}

- (void)adModalDidAppear:(NSNotification *)notification {
    NSLog(@"AD MODAL DID APPEAR");
    NSLog(@"AD IS TYPE %@", [[notification userInfo] objectForKey:MillennialMediaAdTypeKey]);
    NSLog(@"AD APID IS %@", [[notification userInfo] objectForKey:MillennialMediaAPIDKey]);
    NSLog(@"AD IS OBJECT %@", [[notification userInfo] objectForKey:MillennialMediaAdObjectKey]);
}

@end
