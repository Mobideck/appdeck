//
//  MobFoxNativeFormatCreativesManager.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 20.04.2015.
//
//

#import <Foundation/Foundation.h>
#import "MobFoxNativeFormatCreative.h"

@interface MobFoxNativeFormatCreativesManager : NSObject

+ (id) sharedManagerWithPublisherId:(NSString*)publisherId;

- (MobFoxNativeFormatCreative *) getCreativeWithWidth:(NSInteger)width andHeight:(NSInteger)height;

@end
