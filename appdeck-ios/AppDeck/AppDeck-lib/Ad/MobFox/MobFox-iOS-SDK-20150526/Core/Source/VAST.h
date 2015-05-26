//
//  VAST.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 11.02.2014.
//
//

#import <Foundation/Foundation.h>

@class VAST_InLine;
@class VAST_Wrapper;
@class VAST_AdSystem;
@class VAST_Impression;
@class VAST_Creative;
@class VAST_Linear;
@class VAST_MediaFile;
@class VAST_VideoClicks;
@class VAST_CompanionAds;
@class VAST_Companion;
@class VAST_NonLinearAds;
@class VAST_StaticResource;
@class VAST_Tracking;

@interface VAST_Utils : NSObject

+sendTracking:(VAST_Tracking *)tracking;

@end


@interface VAST_Ad  : NSObject

@property (strong, nonatomic) NSString *Id;
@property (strong, nonatomic) NSString *sequence;
@property (strong, nonatomic) VAST_InLine *InLine;
@property (strong, nonatomic) VAST_Wrapper *Wrapper;

@end

@interface VAST_InLine : NSObject

@property (strong, nonatomic) VAST_AdSystem *adSystem;
@property (strong, nonatomic) NSString *adTitle;
@property (strong, nonatomic) NSString *Description;
@property (strong, nonatomic) NSString *advertiser;
@property (strong, nonatomic) NSString *error;
@property (strong, nonatomic) NSMutableArray* impressions;
@property (strong, nonatomic) NSMutableArray* creatives;

@end

@interface VAST_AdSystem  : NSObject

@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *name;

@end

@interface VAST_Impression : NSObject
@property (strong, nonatomic) NSString *Id;
@property (strong, nonatomic) NSString *url;
@end

@interface VAST_Creative : NSObject
@property (strong, nonatomic) NSString *Id;
@property (nonatomic) NSInteger sequence;
@property (strong, nonatomic) NSString *adId;
@property (strong, nonatomic) NSString *apiFramework;
@property (strong, nonatomic) VAST_Linear *linear;
@property (strong, nonatomic) VAST_CompanionAds *companionAds;
@property (strong, nonatomic) VAST_NonLinearAds *nonLinearAds;
@end

@interface VAST_Linear : NSObject
@property (strong, nonatomic) NSString *skipoffset;
@property (strong, nonatomic) NSString *duration;
@property (strong, nonatomic) NSMutableArray* mediaFiles;
@property (strong, nonatomic) NSMutableArray* trackingEvents;
@property (strong, nonatomic) VAST_VideoClicks *videoClicks;
@end

@interface VAST_MediaFile : NSObject
@property (strong, nonatomic) NSString *Id;
@property (strong, nonatomic) NSString *delivery;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *bitrate;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic) BOOL scalable;
@property (nonatomic) BOOL maintainAspectRatio;
@property (strong, nonatomic) NSString *codec;
@property (strong, nonatomic) NSString *apiFramework;
@property (strong, nonatomic) NSString *url;
@end

@interface VAST_VideoClicks : NSObject
@property (strong, nonatomic) NSString *clickThrough;
@property (strong, nonatomic) NSMutableArray* clickTracking;
@property (strong, nonatomic) NSMutableArray* customClicks;
@end

@interface VAST_CompanionAds : NSObject
@property (strong, nonatomic) NSString *required;
@property (strong, nonatomic) NSMutableArray* companions;
@end

@interface VAST_Companion : NSObject
@property (strong, nonatomic) NSString *Id;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic) NSInteger assetWidth;
@property (nonatomic) NSInteger assetHeight;
@property (nonatomic) NSInteger expandedWidth;
@property (nonatomic) NSInteger expandedHeight;
@property (strong, nonatomic) NSString *apiFramework;
@property (strong, nonatomic) NSString *adSlotId;
@property (strong, nonatomic) VAST_StaticResource *staticResource;
@property (strong, nonatomic) NSString *iFrameResource;
@property (strong, nonatomic) NSString *htmlResource;
@property (strong, nonatomic) NSString *altText;
@property (strong, nonatomic) NSString *companionClickThrough;
@property (strong, nonatomic) NSString *companionClickTracking;
@property (strong, nonatomic) NSMutableArray* trackingEvents;
@end

@interface VAST_NonLinearAds : NSObject
@property (strong, nonatomic) NSMutableArray* nonLinears;
@property (strong, nonatomic) NSMutableArray* trackingEvents;
@end

@interface VAST_NonLinear : NSObject
@property (strong, nonatomic) NSString *Id;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic) NSInteger expandedWidth;
@property (nonatomic) NSInteger expandedHeight;
@property (nonatomic) BOOL scalable;
@property (nonatomic) BOOL maintainAspectRatio;
@property (strong, nonatomic) NSString *minSuggestedDuration;
@property (strong, nonatomic) NSString *apiFramework;
@property (strong, nonatomic) VAST_StaticResource *staticResource;
@property (strong, nonatomic) NSString *iFrameResource;
@property (strong, nonatomic) NSString *htmlResource;
@property (strong, nonatomic) NSString *nonLinearClickThrough;
@property (strong, nonatomic) NSString *nonLinearClickTracking;
@end

@interface VAST_StaticResource : NSObject
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString* url;
@end

@interface VAST_Tracking : NSObject
@property (strong, nonatomic) NSString *event;
@property (strong, nonatomic) NSString* progress;
@property (strong, nonatomic) NSString* url;
@end

@interface VAST_Wrapper : NSObject
@property (strong, nonatomic) VAST_AdSystem *adSystem;
@property (strong, nonatomic) NSMutableArray *impressions;
@property (strong, nonatomic) NSString *VASTAdTagUri;
@property (strong, nonatomic) NSString *error;
@property (strong, nonatomic) NSString *extensions;
@property (strong, nonatomic) NSMutableArray* creatives;

@end

