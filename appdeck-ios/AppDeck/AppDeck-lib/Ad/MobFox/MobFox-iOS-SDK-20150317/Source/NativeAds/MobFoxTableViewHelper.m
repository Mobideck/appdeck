//
//  MobFoxTableViewHelper.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 28.05.2014.
//
//

#import "MobFoxTableViewHelper.h"

@interface MobFoxTableViewHelper ()
@property (nonatomic, assign) NSInteger firstAdPosition;
@property (nonatomic, assign) NSInteger adPositionInterval;

@end

@implementation MobFoxTableViewHelper

-(id)init {
    return [self initWithFirstAdPosition:5 andRowsBetweenAds:10];
}

-(id)initWithFirstAdPosition:(NSInteger)positionOfFirstAd andRowsBetweenAds:(NSInteger)rowsOfOriginalContentBetweenAds {
    if(firstAdPosition < 0){
        [NSException raise:@"Invalid first ad position" format:@"First ad position cannot be negative."];
    }
    if(rowsOfOriginalContentBetweenAds < 1) {
        [NSException raise:@"Invalid number of rows of original content" format:@"Number of rows of original content between ads cannot be lower than 1."];
    }
 
    self = [super init];
    if(self) {
        firstAdPosition = positionOfFirstAd;
        adPositionInterval = rowsOfOriginalContentBetweenAds + 1;
    }
    return self;
}

-(BOOL)isAdPosition:(NSInteger)position {
    if (position < firstAdPosition) {
        return NO;
    }
    return ((position - firstAdPosition) % adPositionInterval == 0);
}

-(NSInteger)calculateShiftedNumberOfRowsForNumberOfRows:(NSInteger)originalNumberOfRows {
    return originalNumberOfRows + [self countAdsWithinContent:originalNumberOfRows];
}

-(NSInteger)calculateShiftedPositionForPosition:(NSInteger)originalPosition {
    return originalPosition - [self adsAlreadyShownForPosition:originalPosition];
}

-(NSInteger)countAdsWithinContent:(NSInteger)contentRowCount {
    if (contentRowCount <= firstAdPosition) {
        return 0;
    }
    
    NSInteger originalContentBetweenAds = adPositionInterval - 1;
    if ((contentRowCount - firstAdPosition) % originalContentBetweenAds == 0) {
        return (contentRowCount - firstAdPosition) / originalContentBetweenAds;
    } else {
        return (NSInteger)((double) (contentRowCount - firstAdPosition) / originalContentBetweenAds) + 1;
    }
}

-(NSInteger)adsAlreadyShownForPosition:(NSInteger)position {
    if (position <= firstAdPosition) {
        return 0;
    } else {
        return (NSInteger)((double) (position - firstAdPosition) / adPositionInterval) + 1;
    }
}


@synthesize firstAdPosition;
@synthesize adPositionInterval;

@end
