//
//  KIFTestStep+WebView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+WebView.h"

@implementation KIFTestStep (WebView)

+ (id)stepToTapLink:(NSString *)link
{
    return [self stepToTapLink:link webViewClassName:@"MPAdWebView"];
}

+ (id)stepToTapLink:(NSString *)link webViewClassName:(NSString *)name
{
    NSString *description = [NSString stringWithFormat:@"Clicking link %@", link];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        UIWebView *webView = [[KIFHelper findViewsWithClassNamePrefix:name] lastObject];
        NSString *JS = [NSString stringWithFormat:
                        @"(function() {var anchors = Array.prototype.slice.call(document.querySelectorAll('a'));"
                        @"var anchorWithLink = null;"
                        @"anchors.forEach(function(a) {if (a.innerHTML.match('%@')) anchorWithLink = a;});"
                        @"anchorWithLink.click();"
                        @"return anchorWithLink.innerHTML;})()",
                        link];
        NSString *foundLink = [webView stringByEvaluatingJavaScriptFromString:JS];
        KIFTestCondition(![foundLink isEqualToString:@""], error, @"Could not find link '%@'", link);
        return KIFTestStepResultSuccess;
    }];
}

@end
