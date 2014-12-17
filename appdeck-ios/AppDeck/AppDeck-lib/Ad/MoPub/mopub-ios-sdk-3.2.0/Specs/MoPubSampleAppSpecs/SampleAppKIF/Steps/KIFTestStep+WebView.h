//
//  KIFTestStep+WebView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep.h"

@interface KIFTestStep (WebView)

+ (id)stepToTapLink:(NSString *)link;
+ (id)stepToTapLink:(NSString *)link webViewClassName:(NSString *)name;

@end
