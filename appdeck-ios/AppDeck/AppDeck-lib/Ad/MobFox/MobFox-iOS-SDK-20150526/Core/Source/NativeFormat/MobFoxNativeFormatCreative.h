//
//  NSObject+MobFoxNativeFormatCreative.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 20.04.2015.
//
//

#import <Foundation/Foundation.h>

@interface MobFoxNativeFormatCreative : NSObject

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong) NSString* templateString;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) double prob;

@end
