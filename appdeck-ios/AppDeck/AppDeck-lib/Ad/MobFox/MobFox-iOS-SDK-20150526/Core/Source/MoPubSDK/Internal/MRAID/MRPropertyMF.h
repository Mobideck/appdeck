//
//  MRProperty.h
//  MoPub
//
//  Created by Andrew He on 12/13/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRAdViewMF.h"

@interface MRPropertyMF : NSObject

- (NSString *)description;
- (NSString *)jsonString;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRPlacementTypePropertyMF : MRPropertyMF {
    MRAdViewPlacementType _placementType;
}

@property (nonatomic, assign) MRAdViewPlacementType placementType;

+ (MRPlacementTypePropertyMF *)propertyWithType:(MRAdViewPlacementType)type;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRStatePropertyMF : MRPropertyMF {
    MRAdViewState _state;
}

@property (nonatomic, assign) MRAdViewState state;

+ (MRStatePropertyMF *)propertyWithState:(MRAdViewState)state;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRScreenSizePropertyMF : MRPropertyMF {
    CGSize _screenSize;
}

@property (nonatomic, assign) CGSize screenSize;

+ (MRScreenSizePropertyMF *)propertyWithSize:(CGSize)size;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRSupportsPropertyMF : MRPropertyMF

@property (nonatomic, assign) BOOL supportsSms;
@property (nonatomic, assign) BOOL supportsTel;
@property (nonatomic, assign) BOOL supportsCalendar;
@property (nonatomic, assign) BOOL supportsStorePicture;
@property (nonatomic, assign) BOOL supportsInlineVideo;

+ (NSDictionary *)supportedFeatures;
+ (MRSupportsPropertyMF *)defaultProperty;
+ (MRSupportsPropertyMF *)propertyWithSupportedFeaturesDictionary:(NSDictionary *)dictionary;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRViewablePropertyMF : MRPropertyMF {
    BOOL _isViewable;
}

@property (nonatomic, assign) BOOL isViewable;

+ (MRViewablePropertyMF *)propertyWithViewable:(BOOL)viewable;

@end
