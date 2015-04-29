//
//  ChartboostCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 28.07.2014.
//
//

#import "CustomEventFullscreen.h"
#import <Chartboost/Chartboost.h>


@interface ChartboostCustomEventFullscreen : CustomEventFullscreen <ChartboostDelegate> {
    Class sdk;
}

@end
