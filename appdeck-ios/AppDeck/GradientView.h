//
//  GradientView.h
//  AppDeck
//
//  Created by hanine ben saad on 25/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientView : UIView{
    
    CAGradientLayer*gradient;
}

-(void)setGradientViewWithcolors:(NSArray*)colors;

@end
