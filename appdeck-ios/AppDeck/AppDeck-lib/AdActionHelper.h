//
//  AdActionHelper.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 18/12/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdManager.h"
#import <StoreKit/StoreKit.h>

@interface AdActionHelper : NSObject<SKStoreProductViewControllerDelegate,NSURLSessionDelegate>
{
    NSURLConnection *conn;
    NSURLSession *session;
    NSMutableData	*receivedData;
    NSURLRequest    *currentRequest;
}

@property (weak, nonatomic) AdManager *adManager;
@property (strong, nonatomic)   NSString *url;
@property (strong, nonatomic)   NSString *target;

-(id)initWithURL:(NSString *)url target:(NSString *)target adManager:(AdManager *)adManager;
-(void)cancel;

@end
