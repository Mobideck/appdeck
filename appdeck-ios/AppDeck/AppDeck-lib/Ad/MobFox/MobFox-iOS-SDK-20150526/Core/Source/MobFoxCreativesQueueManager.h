//
//  MobFoxCreativeTypesManager.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 28.04.2015.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    MobFoxCreativeBanner = 1,
    MobFoxCreativeVideo,
    MobFoxCreativeNativeFormat
} MobFoxCreativeType;

@interface MobFoxCreative : NSObject

@property (nonatomic, assign) MobFoxCreativeType type;
@property (nonatomic, assign) float prob;

-(id) initWithType:(MobFoxCreativeType)type andProb:(float)prob;

@end

@interface MobFoxCreativesQueueManager : NSObject

+(id)sharedManagerWithPublisherId:(NSString*)publisherId;

- (NSMutableArray*) getCreativesQueueForBanner;

- (NSMutableArray*) getCreativesQueueForFullscreen;

-(MobFoxCreative*)getCreativeFromQueue:(NSMutableArray*)queue;

@end
