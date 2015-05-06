//
//  GSSDKInfo.h
//  ConversantSDK
//
//  Copyright 2014 Conversant
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const kGSSDKVersion;

@interface GSSDKInfo : NSObject

+ (NSString *)hashedDeviceId;
+ (void)setGUID:(NSString *)a_GUID;
+ (void)updateLocation:(CLLocation *)a_location;


@end
