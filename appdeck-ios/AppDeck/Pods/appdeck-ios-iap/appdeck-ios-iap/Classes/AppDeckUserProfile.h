//
//  AppDeckUserProfile.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 07/01/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

//const char * kAppDeckProfileKey;

typedef enum {
    ProfileEducationNotSet = 0,
    ProfileEducationOther,
    ProfileEducationNone,
    ProfileEducationHighSchool,
    ProfileEducationInCollege,
    ProfileEducationSomeCollege,
    ProfileEducationAssociates,
    ProfileEducationBachelors,
    ProfileEducationMasters,
    ProfileEducationDoctorate
} ProfileEducation;

typedef enum {
    ProfileGenderNotSet = 0,
    ProfileGenderOther,
    ProfileGenderMale,
    ProfileGenderFemale
} ProfileGender;

/*typedef enum {
    ProfileEthnicityNotSet = 0,
    ProfileEthnicityMiddleEastern,
    ProfileEthnicityAsian,
    ProfileEthnicityBlack,
    ProfileEthnicityHispanic,
    ProfileEthnicityIndian,
    ProfileEthnicityNativeAmerican,
    ProfileEthnicityPacificIslander,
    ProfileEthnicityWhite,
    ProfileEthnicityOther
} ProfileEthnicity;*/

typedef enum {
    ProfileMaritalNotSet = 0,
    ProfileMaritalOther,
    ProfileMaritalSingle,
    ProfileMaritalRelationship,
    ProfileMaritalMarried,
    ProfileMaritalDivorced,
    ProfileMaritalEngaged
} ProfileMaritalStatus;

/*typedef enum {
    ProfileSexualOrientationNotSet = 0,
    ProfileSexualOrientationOther,
    ProfileSexualOrientationGay,
    ProfileSexualOrientationStraight,
    ProfileSexualOrientationBisexual
} ProfileSexualOrientation;*/

typedef enum {
    ProfileHasChildrenNotSet = 0,
    ProfileHasChildrenTrue,
    ProfileHasChildrenFalse
} ProfileHasChildren;

@interface AppDeckUserProfile : NSObject
{
    NSMutableDictionary *profileData;
}

-(id)initWithKey:(NSString *)key;

-(void)setValue:(id)value forKey:(id)key;

-(NSDictionary *)getComputedData;

@property (nonatomic, strong)   NSString *key;

@property (nonatomic, strong)   NSString *postal;
@property (nonatomic, strong)   NSString *city;
@property (nonatomic, strong)   NSString *yearOfBirth;
@property (nonatomic, assign)   ProfileGender gender;
@property (nonatomic, strong)   NSString *login;
@property (nonatomic, strong)   NSString *session;
@property (nonatomic, strong)   NSString *facebook;
@property (nonatomic, strong)   NSString *msn;
@property (nonatomic, strong)   NSString *twitter;
@property (nonatomic, strong)   NSString *skype;
@property (nonatomic, strong)   NSString *yahoo;
@property (nonatomic, strong)   NSString *googleplus;
@property (nonatomic, strong)   NSString *linkedin;
@property (nonatomic, strong)   NSString *youtube;
@property (nonatomic, strong)   NSString *viadeo;
@property (nonatomic, strong)   NSString *mail;
@property (nonatomic, assign)   ProfileEducation education;
@property (nonatomic, strong)   NSString *dateOfBirth;
@property (nonatomic, strong)   NSString *income;
@property (nonatomic, strong)   NSString *age;
@property (nonatomic, strong)   NSString *areaCode;
@property (nonatomic, strong)   NSString *interests;
@property (nonatomic, assign)   ProfileMaritalStatus maritalStatus;
@property (nonatomic, strong)   NSString *language;
@property (nonatomic, assign)   ProfileHasChildren hasChildren;
@property (nonatomic, strong)   NSMutableDictionary *custom;

@property (nonatomic, copy)   NSString *openUDID;
@property (nonatomic, copy)   NSString *secureUDID;
@property (nonatomic, copy)   NSString *udfa;


// live configuration
@property (assign, nonatomic) BOOL enable_prefetch;
@property (assign, nonatomic) BOOL enable_ad;


@end
