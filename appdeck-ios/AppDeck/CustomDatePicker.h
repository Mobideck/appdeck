//
//  CustomDatePicker.h
//  AppDeck
//
//  Created by hanine ben saad on 19/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDeckApiCall.h"

@interface CustomDatePicker : UIAlertController{
  
}

+(void)PresentInVC:(UIViewController*)vc fromCall:(AppDeckApiCall*)call;
@end
