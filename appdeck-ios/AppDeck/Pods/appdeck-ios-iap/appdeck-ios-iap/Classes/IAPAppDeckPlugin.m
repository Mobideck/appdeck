//
//  IAPAppDeckPlugin.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/05/2016.
//  Copyright © 2016 Mathieu De Kermadec. All rights reserved.
//

#import "IAPAppDeckPlugin.h"

#import "RMStore.h"

#import "AppDeckProgressHUD.h"
#import "LoaderChildViewController.h"

#define NILABLE(obj) ((obj) != nil ? (NSObject *)(obj) : (NSObject *)[NSNull null])

@implementation IAPAppDeckPlugin

+ (void)load
{
    [AppDeckPluginManager registerAppDeckPlugin:[[self alloc] init] withCommands:@[@"ipasetup", @"iappurchase", @"iaplistproduct", @"iaprestore", @"iapgetreceipt"]];
}

-(BOOL)iapsetup:(AppDeckApiCall *)call
{
    return YES;
}

-(BOOL)iappurchase:(AppDeckApiCall *)call
{
    id productId = [call.param objectForKey:@"productId"];
    if (![productId isKindOfClass:[NSString class]]) {
        [call sendCallBackWithErrorMessage:@"ProductId must be a string"];
        return NO;
    }
    
    NSLog(@"ProductId: %@", productId);
    
    AppDeckProgressHUD *appdeckProgressHUD = [AppDeckProgressHUD progressHUDForViewController:call.child];
    appdeckProgressHUD.graceTime = 0.0;
    appdeckProgressHUD.minShowTime = 0.0;
    [appdeckProgressHUD show];
    
    
    NSSet *products = [NSSet setWithArray:@[productId]];
    [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        
        for (SKProduct *product in products) {
            if ([product.productIdentifier isEqualToString:productId])
            {
                /* @{
                    @"productId": NILABLE(product.productIdentifier),
                    @"title": NILABLE(product.localizedTitle),
                    @"description": NILABLE(product.localizedDescription),
                    @"price": NILABLE([RMStore localizedPriceOfProduct:product]),
                    };*/
                NSLog(@"Product found and loaded let's try to buy it: %@", product);
                [[RMStore defaultStore] addPayment:productId success:^(SKPaymentTransaction *transaction) {
                    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
                    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
                    NSString *encReceipt = [receiptData base64EncodedStringWithOptions:0];
                    NSDictionary *result = @{
                                             @"transactionId": NILABLE(transaction.transactionIdentifier),
                                             @"receipt": NILABLE(encReceipt)
                                             };
                    NSLog(@"Result: %@", result);
                    [appdeckProgressHUD hide];
                    [call sendCallbackWithResult:@[result]];
                    
                } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [appdeckProgressHUD hide];
                    [call sendCallBackWithError:error];
                }];
                return;
            }
        }
     [call sendCallBackWithErrorMessage:@"Product not found"];
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
        [appdeckProgressHUD hide];
        [call sendCallBackWithError:error];
    }];
    
    return YES;
}

-(BOOL)iaplistproduct:(AppDeckApiCall *)call
{
    id productIds = call.param;
    
    if (![productIds isKindOfClass:[NSArray class]]) {
        [call sendCallBackWithErrorMessage:@"ProductIds must be an array"];
        return NO;
    }
    
    NSSet *products = [NSSet setWithArray:productIds];
    
    NSLog(@"Products: %@", products);
    
    [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        NSMutableArray *validProducts = [NSMutableArray array];
        for (SKProduct *product in products) {
            [validProducts addObject:@{
                                       @"productId": NILABLE(product.productIdentifier),
                                       @"title": NILABLE(product.localizedTitle),
                                       @"description": NILABLE(product.localizedDescription),
                                       @"price": NILABLE([RMStore localizedPriceOfProduct:product]),
                                       }];
        }
        [result setObject:validProducts forKey:@"products"];
        [result setObject:invalidProductIdentifiers forKey:@"invalidProductsIds"];
    
        NSLog(@"Result: %@", result);
        
        [call sendCallbackWithResult:@[result]];

    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
        [call sendCallBackWithError:error];
    }];
    return YES;
}

-(BOOL)iaprestore:(AppDeckApiCall *)call
{
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
        NSMutableArray *validTransactions = [NSMutableArray array];
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        for (SKPaymentTransaction *transaction in transactions) {
            NSString *transactionDateString = [formatter stringFromDate:transaction.transactionDate];
            [validTransactions addObject:@{
                                           @"productId": NILABLE(transaction.payment.productIdentifier),
                                           @"date": NILABLE(transactionDateString),
                                           @"transactionId": NILABLE(transaction.transactionIdentifier),
                                           @"transactionState": NILABLE([NSNumber numberWithInteger:transaction.transactionState])
                                           }];
        }
        [result setObject:validTransactions forKey:@"transactions"];
        
        [call sendCallbackWithResult:@[result]];
    } failure:^(NSError *error) {
        [call sendCallBackWithError:error];
    }];
    return YES;
}

-(BOOL)iapgetreceipt:(AppDeckApiCall *)call
{
    [[RMStore defaultStore] refreshReceiptOnSuccess:^{
        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
        NSString *encReceipt = [receiptData base64EncodedStringWithOptions:0];
        NSDictionary *result = @{@"receipt": NILABLE(encReceipt) };
        [call sendCallbackWithResult:@[result]];
    } failure:^(NSError *error) {
        [call sendCallBackWithError:error];
    }];
    return YES;
}

@end
