//
//  AppDeckUserProfile.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 07/01/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeckUserProfile.h"
#import <AdSupport/AdSupport.h>
#import "OpenUDID.h"
#import "SecureUDID.h"

//const char * kAppDeckProfileKey = "#appdeck#profile#";

@implementation AppDeckUserProfile

-(id)initWithKey:(NSString *)key;
{
    self = [super init];
    
    if (self)
    {
        self.key = [NSString stringWithFormat:@"#appdeck#profile#%@", key];
        NSDictionary *currentProfile = [[NSUserDefaults standardUserDefaults] objectForKey:self.key];
                                        
                                        //[NSString stringWithCString:kAppDeckProfileKey encoding:NSUTF8StringEncoding]];
        
        if (currentProfile == nil)
        {
            currentProfile = [[NSMutableDictionary alloc] init];
            [currentProfile setValue:@"1" forKey:@"enable_prefetch"];
            [currentProfile setValue:@"1" forKey:@"enable_ad"];
        }
        
        profileData = [currentProfile mutableCopy];
        
        [self readData];

    }
    
    return self;
}

-(void)setValue:(id)value forKey:(id)key
{
    if (key == nil || key == [NSNull null])
        return;
    
    if (value == nil || value == [NSNull null])
        value = @"";
    
    NSString *keyString = [NSString stringWithFormat:@"%@", key];
    NSString *valueString = [NSString stringWithFormat:@"%@", value];
    
    if ([valueString isEqualToString:@""])
        [profileData removeObjectForKey:keyString];
    else
        [profileData setObject:valueString forKey:keyString];
    
    [self readData];
    
//    [[NSUserDefaults standardUserDefaults] setObject:profileData forKey:[NSString stringWithCString:kAppDeckProfileKey encoding:NSUTF8StringEncoding]];
    [[NSUserDefaults standardUserDefaults] setObject:profileData forKey:self.key];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(NSDictionary *)getComputedData
{
    NSMutableDictionary *computedData = [profileData mutableCopy];
    [computedData setObject:self.openUDID forKey:@"openudid"];
    [computedData setObject:self.udfa forKey:@"udfa"];
    [computedData setObject:self.secureUDID forKey:@"secureudid"];
    return computedData;
}

-(void)readData
{
    // live configuration
    NSString *enable_prefetch = [profileData objectForKey:@"enable_prefetch"];
    if ([enable_prefetch isEqualToString:@"0"])
        self.enable_prefetch = NO;
    else
        self.enable_prefetch = YES;
    
    NSString *enable_ad = [profileData objectForKey:@"enable_ad"];
    if ([enable_ad isEqualToString:@"0"])
        self.enable_ad = NO;
    else
        self.enable_ad = YES;

    
    // geo
    self.postal = [profileData objectForKey:@"postal"];
    self.city = [profileData objectForKey:@"city"];
    self.areaCode = [profileData objectForKey:@"areaCode"];
    
    // birth
    self.yearOfBirth = [profileData objectForKey:@"yearOfBirth"];
    self.dateOfBirth = [profileData objectForKey:@"dateOfBirth"];
    self.age = [profileData objectForKey:@"age"];
    
    // gender
    NSString *gender = [[[profileData objectForKey:@"gender"] lowercaseString] substringToIndex:1];
    if ([gender isEqualToString:@"h"] || [gender isEqualToString:@"m"] || [gender isEqualToString:@"1"])
        self.gender = ProfileGenderMale;
    else if ([gender isEqualToString:@"f"] || [gender isEqualToString:@"w"] || [gender isEqualToString:@"0"])
        self.gender = ProfileGenderFemale;
    else
        self.gender = ProfileGenderNotSet;

    // user ID
    self.login = [profileData objectForKey:@"login"];
    self.session = [profileData objectForKey:@"session"];
    self.facebook = [profileData objectForKey:@"facebook"];
    self.mail = [profileData objectForKey:@"mail"];
    self.msn = [profileData objectForKey:@"msn"];
    self.twitter = [profileData objectForKey:@"twitter"];
    self.skype = [profileData objectForKey:@"skype"];
    self.yahoo = [profileData objectForKey:@"yahoo"];
    self.googleplus = [profileData objectForKey:@"googleplus"];
    self.linkedin = [profileData objectForKey:@"linkedin"];
    self.youtube = [profileData objectForKey:@"youtube"];
    self.viadeo = [profileData objectForKey:@"viadeo"];
    
    // education
    NSString *education = [[profileData objectForKey:@"education"] lowercaseString];
    if ([education isEqualToString:@"other"])
        self.education = ProfileEducationOther;
    else if ([education isEqualToString:@"none"])
        self.education = ProfileEducationNone;
    else if ([education isEqualToString:@"highschool"])
        self.education = ProfileEducationHighSchool;
    else if ([education isEqualToString:@"incollege"])
        self.education = ProfileEducationInCollege;
    else if ([education isEqualToString:@"somecollege"])
        self.education = ProfileEducationSomeCollege;
    else if ([education isEqualToString:@"college"])
        self.education = ProfileEducationSomeCollege;
    else if ([education isEqualToString:@"associates"])
        self.education = ProfileEducationAssociates;
    else if ([education isEqualToString:@"bachelors"])
        self.education = ProfileEducationBachelors;
    else if ([education isEqualToString:@"masters"])
        self.education = ProfileEducationMasters;
    else if ([education isEqualToString:@"doctorate"])
        self.education = ProfileEducationDoctorate;
    else
        self.education = ProfileEducationNotSet;
    
    // income
    self.income = [profileData objectForKey:@"income"];
    
    // interests
    self.interests = [profileData objectForKey:@"interests"];
    /*
     Games – This is fairly obvious but any 2D or 3D game (The most popular category in the store).
     Entertainment – These are novelty Apps for pure enjoyment. Do you want to see what you would look like bald?
     Utilities – This is everything from alarm clocks to barcode scanners to levels for hanging pictures.
     Social Networking – If your App is an extension of a social networking platform or intended to help users communicate or network with each other, Social Networking might be your best bet.
     Music – If your App is for playing music, modifying music, or identifying music, it belongs here.
     Productivity – For any App which helps users be more productive such as to-do lists, calendars, or note taking (Evernote)!
     Lifestyle – This is a more general App category including things like cooking Apps or journals.
     Reference – If your App is a reference guide to anything from anatomy to bar tending, this is a good choice.
     Travel – For all Apps that are travel related! If your user will use your App while traveling or planning for travel, put it here.
     Sports – This is a fairly obvious category. If it is sports related in anyway, this is your category.
     Navigation – If you are helping people find things, Navigation is the correct category.
     Healthcare & Fitness – If your App is meant to improve a users health or fitness level, use this category!
     News – If the focus of your App is to let users keep up with some type of news, News is the obvious choice.
     Photography – If you help users view, share or modify photographs, pick Photography.
     Finance – Are you helping users manage money, make financial decisions, or keep up with market conditions? This is your category if the answer is yes.
     Business – This is a misleading category. A lot of general business utilities will fall here.
     Education – If you feel like you’re helping users to learn facts or skills, education might be a wise choice.
     Weather – This is another obvious category!
     Books – This is for all things book related, interactive or not!
     Medical – If the focus of your App is for medical professionals (doctors, nurses, paramedics) or to provide medical information, pick medical.
     */
    
    // marital status
    NSString *maritalStatus = [[profileData objectForKey:@"maritalStatus"] lowercaseString];
    if ([maritalStatus isEqualToString:@"other"])
        self.maritalStatus = ProfileMaritalOther;
    else if ([maritalStatus isEqualToString:@"single"])
        self.maritalStatus = ProfileMaritalSingle;
    else if ([maritalStatus isEqualToString:@"relationship"])
        self.maritalStatus = ProfileMaritalRelationship;
    else if ([maritalStatus isEqualToString:@"married"])
        self.maritalStatus = ProfileMaritalMarried;
    else if ([maritalStatus isEqualToString:@"divorced"])
        self.maritalStatus = ProfileMaritalDivorced;
    else if ([maritalStatus isEqualToString:@"engaged"])
        self.maritalStatus = ProfileMaritalEngaged;
    else
        self.maritalStatus = ProfileMaritalNotSet;
    
    // language
    self.language = [profileData objectForKey:@"language"];
    if (self.language == nil)
        self.language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    // has children
    NSString *hasChildren = [[profileData objectForKey:@"hasChildren"] lowercaseString];
    if ([hasChildren isEqualToString:@"1"] || [hasChildren isEqualToString:@"y"] || [hasChildren isEqualToString:@"o"])
        self.hasChildren = ProfileHasChildrenTrue;
    if ([hasChildren isEqualToString:@"0"] || [hasChildren isEqualToString:@"n"])
        self.hasChildren = ProfileHasChildrenFalse;
    else
        self.hasChildren = ProfileHasChildrenNotSet;
    
    // custom
    self.custom = [profileData objectForKey:@"custom"];
    
    // generated
    self.udfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    self.openUDID = [OpenUDID value];
    NSString *domain     = @"com.mobideck.appdeck";
    NSString *key        = @"JSAPI: Event: Exception while writing JSon: %@: %@";

    if (self.secureUDID == nil)
    {
        // use try /catch block as sometime there is an unexpected
        // +[UIPasteboard _accessibilityUseQuickSpeakPasteBoard]: unrecognized selector sent to class 0x38eacb60
        @try {
            self.secureUDID = [SecureUDID UDIDForDomain:domain usingKey:key];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception:%@", exception);
            self.secureUDID = nil;
        }
        @finally {
            //Display Alternative
        }
    }

}

@end
