//
//  WideSpaceAdEngine.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdEngine.h"
#import "SwelenAds-50000c/SwelenSDK/swAdAPI.h"

@interface SwelenAdEngine : AppDeckAdEngine

@property (strong, nonatomic)   NSString *bannerSID;
@property (strong, nonatomic)   NSString *rectangleSID;
@property (strong, nonatomic)   NSString *interstitialSID;
@property (strong, nonatomic)   NSString *leaderboardSID;
//@property (strong, nonatomic)   NSString *leaderboardSIDnomargin;
@property (strong, nonatomic)   NSString *squareSID;

@end
