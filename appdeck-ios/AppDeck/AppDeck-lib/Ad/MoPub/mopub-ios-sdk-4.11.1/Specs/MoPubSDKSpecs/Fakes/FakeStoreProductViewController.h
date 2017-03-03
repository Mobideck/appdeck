//
//  FakeStoreProductViewController.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface FakeStoreProductViewController : UIViewController

@property (nonatomic, weak) id<SKStoreProductViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *storeItemIdentifier;
@property (nonatomic, copy) void (^completionBlock)(BOOL result, NSError *error);

- (SKStoreProductViewController *)masquerade;
- (void)loadProductWithParameters:(NSDictionary *)parameters completionBlock:(void (^)(BOOL, NSError *))block;

@end
