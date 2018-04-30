//
//  MySlider.h
//  AppDeck
//
//  Created by hanine ben saad on 24/04/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDeckApiCall.h"

@interface MySlider : UIView{
    
    
}


-(void)getValueWithCompletion: (void(^)(NSInteger *))completion;
-(void)showInController:(UIViewController*)vc fromCall:(AppDeckApiCall*)mcall;
-(void)initialize;
@end
