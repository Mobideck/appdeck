//
//  MPURLResolver.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGlobalMF.h"

@protocol MPURLResolverDelegateMF;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_5_0
@interface MPURLResolverMF : NSObject <NSURLConnectionDataDelegate>
#else
@interface MPURLResolverMF : NSObject
#endif

@property (nonatomic, assign) id<MPURLResolverDelegateMF> delegate;

+ (MPURLResolverMF *)resolver;
- (void)startResolvingWithURL:(NSURL *)URL delegate:(id<MPURLResolverDelegateMF>)delegate;
- (void)cancel;

@end

@protocol MPURLResolverDelegateMF <NSObject>

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL;
- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL;
- (void)openURLInApplication:(NSURL *)URL;
- (void)failedToResolveURLWithError:(NSError *)error;

@end
