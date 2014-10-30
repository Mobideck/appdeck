//
//  FakeStoreProductViewController.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface FakeStoreProductViewController : UIViewController

@property (nonatomic, assign) id<SKStoreProductViewControllerDelegate> delegate;
@property (nonatomic, assign) NSString *storeItemIdentifier;
@property (nonatomic, copy) void (^completionBlock)(BOOL result, NSError *error);

- (SKStoreProductViewController *)masquerade;
- (void)loadProductWithParameters:(NSDictionary *)parameters completionBlock:(void (^)(BOOL, NSError *))block;

@end
