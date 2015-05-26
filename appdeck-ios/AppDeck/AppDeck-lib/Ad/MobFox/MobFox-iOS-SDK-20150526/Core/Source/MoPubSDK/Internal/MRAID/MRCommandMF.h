//
//  MRCommand.h
//  MoPub
//
//  Created by Andrew He on 12/19/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRCommandMF;

@protocol MRCommandDelegateMF <NSObject>

- (void)mrCommand:(MRCommandMF *)command createCalendarEventWithParams:(NSDictionary *)params;
- (void)mrCommand:(MRCommandMF *)command playVideoWithURL:(NSURL *)url;
- (void)mrCommand:(MRCommandMF *)command storePictureWithURL:(NSURL *)url;
- (void)mrCommand:(MRCommandMF *)command shouldUseCustomClose:(BOOL)useCustomClose;
- (void)mrCommand:(MRCommandMF *)command openURL:(NSURL *)url;
- (void)mrCommand:(MRCommandMF *)command expandWithParams:(NSDictionary *)params;
- (void)mrCommandClose:(MRCommandMF *)command;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRCommandMF : NSObject

@property (nonatomic, assign) id<MRCommandDelegateMF> delegate;

+ (id)commandForString:(NSString *)string;

// returns YES by default for user safety
- (BOOL)requiresUserInteractionForPlacementType:(NSUInteger)placementType;

- (BOOL)executeWithParams:(NSDictionary *)params;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRCloseCommandMF : MRCommandMF

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRExpandCommandMF : MRCommandMF

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRUseCustomCloseCommandMF : MRCommandMF

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MROpenCommandMF : MRCommandMF

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRCreateCalendarEventCommandMF : MRCommandMF

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRPlayVideoCommandMF : MRCommandMF

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRStorePictureCommandMF : MRCommandMF

@end
