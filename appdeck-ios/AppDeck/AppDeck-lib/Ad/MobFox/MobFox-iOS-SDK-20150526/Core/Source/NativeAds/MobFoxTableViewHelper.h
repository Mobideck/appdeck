//
//  MobFoxTableViewHelper.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 28.05.2014.
//
//

#import <Foundation/Foundation.h>

@interface MobFoxTableViewHelper : NSObject

- (id)initWithFirstAdPosition:(NSInteger)positionOfFirstAd andRowsBetweenAds:(NSInteger)rowsOfOriginalContentBetweenAds;

- (NSInteger) calculateShiftedNumberOfRowsForNumberOfRows:(NSInteger)originalNumberOfRows;

- (NSInteger) calculateShiftedPositionForPosition:(NSInteger)originalPosition;

- (BOOL) isAdPosition:(NSInteger)position;

@end
