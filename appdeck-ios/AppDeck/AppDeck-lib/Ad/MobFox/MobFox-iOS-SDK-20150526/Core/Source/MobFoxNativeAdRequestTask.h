//
//  MobFoxNativeAdRequestTask.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 17.07.2014.
//
//

#import "MFCustomEventFullscreen.h"
#import "MobFoxNativeAdController.h"

@interface MobFoxNativeAdRequestTask : NSObject

extern NSString* const MobFoxNativeAdErrorDomain;

@property (nonatomic, assign) IBOutlet __unsafe_unretained id <MobFoxNativeAdDelegate> delegate;
@property (nonatomic, strong) NSString* userAgent;

- (void) startRequestWithUrl:(NSURL*)url;

@end
