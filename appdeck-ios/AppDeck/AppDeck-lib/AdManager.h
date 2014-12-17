//
//  AdManager.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 04/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDeckAdConfig.h"
//#import "AppDeckAdUsage.h"
#import "LoaderViewController.h"
#import "PageViewController.h"
#import "SwipeViewController.h"
#import "AppDeckAdViewController.h"
#import "AppDeckAdPreload.h"
#import "AppDeckAdEngine.h"

#define APPDECK_AD_CLOUD_VERSION    @"1"

@class AppDeckAdUsage;
@class AdActionHelper;
/*
typedef enum {
    AdManagerEducationNotSet = 0,
    AdManagerEducationOther,
    AdManagerEducationNone,
    AdManagerEducationHighSchool,
    AdManagerEducationInCollege,
    AdManagerEducationSomeCollege,
    AdManagerEducationAssociates,
    AdManagerEducationBachelors,
    AdManagerEducationMasters,
    AdManagerEducationDoctorate
} AdManagerEducation;

typedef enum {
    AdManagerGenderNotSet = 0,
    AdManagerGenderOther,
    AdManagerGenderMale,
    AdManagerGenderFemale
} AdManagerGender;

typedef enum {
    AdManagerEthnicityNotSet = 0,
    AdManagerEthnicityMiddleEastern,
    AdManagerEthnicityAsian,
    AdManagerEthnicityBlack,
    AdManagerEthnicityHispanic,
    AdManagerEthnicityIndian,
    AdManagerEthnicityNativeAmerican,
    AdManagerEthnicityPacificIslander,
    AdManagerEthnicityWhite,
    AdManagerEthnicityOther
} AdManagerEthnicity;

typedef enum {
    AdManagerMaritalNotSet = 0,
    AdManagerMaritalOther,
    AdManagerMaritalSingle,
    AdManagerMaritalRelationship,
    AdManagerMaritalMarried,
    AdManagerMaritalDivorced,
    AdManagerMaritalEngaged
} AdManagerMaritalStatus;

typedef enum {
    AdManagerSexualOrientationNotSet = 0,
    AdManagerSexualOrientationOther,
    AdManagerSexualOrientationGay,
    AdManagerSexualOrientationStraight,
    AdManagerSexualOrientationBisexual
} AdManagerSexualOrientation;

typedef enum {
    AdManagerHasChildrenNotSet = 0,
    AdManagerHasChildrenTrue,
    AdManagerHasChildrenFalse
} AdManagerHasChildren;*/

@interface AdManager : NSObject
{
    NSMutableDictionary *adEngines;
    
    /*NSMutableArray *bannerAds;
    NSMutableArray *rectangleAds;
    NSMutableArray *interstitialAds;
    
    NSTimer *timer;
    
    JSonHTTPApi *jsonapi;*/
    
    AdActionHelper *adAction;
}

@property (nonatomic, assign)    BOOL   enable_debug;



@property (weak, nonatomic) LoaderViewController *loader;

@property (strong, nonatomic)    UIViewController *fakeCtl;
/*
@property (strong, nonatomic)   NSMutableArray *adTypes;
@property (strong, nonatomic)   NSMutableDictionary *adConfigs;
@property (strong, nonatomic)   NSMutableDictionary *adUsages;
@property (strong, nonatomic)   NSMutableDictionary *adPreloads;

 */
+(NSString *)AdManagerEventToString:(AdManagerEvent)event;

+(void)registerAdEngine:(NSString *)name class:(NSString *)className;
+(NSMutableDictionary *)getAvailableAdEngines;

-(id)initWithLoader:(LoaderViewController *)loader;

-(void)pageViewController:(PageViewController *)page appearWithEvent:(AdManagerEvent)event;

-(void)ad:(AppDeckAdViewController *)ad didUpdateState:(AppDeckAdState)state;

-(BOOL)handleActionURL:(NSString *)url withTarget:(NSString *)target;

-(void)clean;


-(AppDeckAdEngine *)adEngineFromId:(NSString *)engineId type:(NSString *)type config:(NSDictionary *)config;
//-(AppDeckAdEngine *)adEngineForRation:(AdRation *)adRation AndAdConfig:(NSDictionary *)adConfig;

/*@property (nonatomic, assign) AdManagerEducation education;
@property (nonatomic, assign) AdManagerGender gender;
@property (nonatomic, assign) AdManagerEthnicity ethnicity;
@property (nonatomic, assign) AdManagerMaritalStatus maritalStatus;
@property (nonatomic, assign) AdManagerSexualOrientation orientation;
@property (nonatomic, assign) AdManagerHasChildren hasChildren;
@property (nonatomic, assign) int   yearOfBirth;
@property (nonatomic, assign) int   monthOfBirth;
@property (nonatomic, assign) int   dayOfBirth;
@property (nonatomic, assign) int   income; // Approximate annual household income (in US Dollars)
@property (nonatomic, copy)   NSString *language; // Values are expected in 3 letter codes from ISO 639-2/5. http://en.wikipedia.org/wiki/List_of_ISO_639-2_codes
@property (nonatomic, copy)   NSString *zipCode;
@property (nonatomic, copy)   NSString *areaCode;
@property (nonatomic, copy)   NSString *loginId;
@property (nonatomic, copy)   NSString *sessionId;
@property (nonatomic, copy)   NSString *facebookId;
@property (nonatomic, copy)   NSString *openUDID;
@property (nonatomic, copy)   NSString *advertisementId;*/

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, retain) NSMutableDictionary *carrierInfo;

@end
