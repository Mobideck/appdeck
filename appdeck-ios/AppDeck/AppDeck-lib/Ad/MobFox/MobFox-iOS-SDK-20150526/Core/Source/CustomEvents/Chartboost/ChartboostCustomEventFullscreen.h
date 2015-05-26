//
//  ChartboostCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 28.07.2014.
//
//

#import "MFCustomEventFullscreen.h"
#import <Chartboost/Chartboost.h>


@interface ChartboostCustomEventFullscreen : MFCustomEventFullscreen <ChartboostDelegate> {
    Class sdk;
}

@end
