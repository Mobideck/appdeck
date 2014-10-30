//
//  KIFTestStep+TableView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep.h"

@interface KIFTestStep (TableView)

+ (id)stepToActuallyTapRowInTableViewWithAccessibilityLabel:(NSString*)tableViewLabel atIndexPath:(NSIndexPath *)indexPath;

@end
