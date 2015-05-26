//
//  CustomEvent.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 10.03.2014.
//
//

#import <Foundation/Foundation.h>

@interface MFCustomEvent : NSObject
@property (nonatomic, strong) NSString* className;
@property (nonatomic, strong) NSString* optionalParameter;
@property (nonatomic, strong) NSString* pixelUrl;
@end
