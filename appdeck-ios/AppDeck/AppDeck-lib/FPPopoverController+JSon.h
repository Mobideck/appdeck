//
//  FPPopoverController+JSon.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "FPPopover/FPPopoverController.h"

@interface FPPopoverController (JSon)

+(FPPopoverController *)popoverControllerFromJSon:(NSString *)json fromView:(UIView *)view relativeToURL:(NSURL *)base_url error:(NSError **)error;

@end
