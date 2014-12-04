//
//  KIFTestStep+TableView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+TableView.h"
#import "UIApplication-KIFAdditions.h"
#import "UIAccessibilityElement-KIFAdditions.h"
#import "UIView-KIFAdditions.h"
#import "CGGeometry-KIFAdditions.h"

@implementation KIFTestStep (TableView)

+ (id)stepToActuallyTapRowInTableViewWithAccessibilityLabel:(NSString*)tableViewLabel atIndexPath:(NSIndexPath *)indexPath
{
    NSString *description = [NSString stringWithFormat:@"Step to tap row %d in tableView with label %@", [indexPath row], tableViewLabel];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
        UIAccessibilityElement *element = [[UIApplication sharedApplication] accessibilityElementWithLabel:tableViewLabel];
        KIFTestCondition(element, error, @"View with label %@ not found", tableViewLabel);
        UITableView *tableView = (UITableView*)[UIAccessibilityElement viewContainingAccessibilityElement:element];

        KIFTestCondition([tableView isKindOfClass:[UITableView class]], error, @"Specified view is not a UITableView");

        KIFTestCondition(tableView, error, @"Table view with label %@ not found", tableViewLabel);

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            KIFTestCondition([indexPath section] < [tableView numberOfSections], error, @"Section %d is not found in '%@' table view", [indexPath section], tableViewLabel);
            KIFTestCondition([indexPath row] < [tableView numberOfRowsInSection:[indexPath section]], error, @"Row %d is not found in section %d of '%@' table view", [indexPath row], [indexPath section], tableViewLabel);
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
            cell = [tableView cellForRowAtIndexPath:indexPath];
        }
        KIFTestCondition(cell, error, @"Table view cell at index path %@ not found", indexPath);

        CGRect cellFrame = [cell.contentView convertRect:[cell.contentView frame] toView:tableView];

        // This fixes the KIF bug which causes off-screen cells to not be tappable (at times).
        cellFrame = CGRectIntersection(cellFrame, tableView.bounds);
        [tableView tapAtPoint:CGPointCenteredInRect(cellFrame)];

        return KIFTestStepResultSuccess;
    }];
}

@end
