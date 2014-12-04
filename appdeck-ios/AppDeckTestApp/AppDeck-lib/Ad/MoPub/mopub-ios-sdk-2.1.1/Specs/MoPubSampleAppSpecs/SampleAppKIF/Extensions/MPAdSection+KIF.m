//
//  MPAdSection+KIF.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdSection+KIF.h"

@implementation MPAdSection (KIF)

+ (MPAdInfo *)adInfoAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sections = [self adSections];
    MPAdSection *section = sections[indexPath.section];
    return [section adAtIndex:indexPath.row];
}

+ (NSIndexPath *)indexPathForAd:(NSString *)adTitle inSection:(NSString *)sectionTitle
{
    NSArray *sections = [self adSections];
    NSUInteger section;
    NSUInteger row;
    for (section = 0 ; section < sections.count ; section++) {
        MPAdSection *adSection = sections[section];
        if ([adSection.title isEqualToString:sectionTitle]) {
            for (row = 0 ; row < adSection.count ; row++) {
                MPAdInfo *adInfo = [adSection adAtIndex:row];
                if ([adInfo.title isEqualToString:adTitle]) {
                    return [NSIndexPath indexPathForRow:row inSection:section];
                }
            }
        }
    }

    NSLog(@"================> COULD NOT FIND INDEX PATH FOR AD TITLED: %@ IN SECTION: %@", adTitle, sectionTitle);

    return nil;
}

@end
