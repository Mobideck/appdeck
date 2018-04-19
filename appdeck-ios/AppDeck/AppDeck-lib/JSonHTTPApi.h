//
//  JSonHTTPApi.h
//  reddit
//
//  Created by Mathieu De Kermadec on 03/11/12.
//  Copyright (c) 2012 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void ( ^JSonHTTPApiCallBack )( NSDictionary *, NSError *error ) ;


@interface JSonHTTPApi : NSObject <NSURLSessionDelegate>
{
	NSURLConnection	*conn;
    NSURLSession*session;
	NSMutableData	*receivedData;

}

/*@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *params;*/
@property (nonatomic, strong) JSonHTTPApiCallBack callback;
@property (nonatomic, strong) NSMutableURLRequest *request;

+ ( JSonHTTPApi * )apiWithURL:(NSString *)url params:(NSDictionary * )params
                     callback: ( JSonHTTPApiCallBack )callback;


+ ( JSonHTTPApi * )apiWithRequest:(NSURLRequest *)request callback: ( JSonHTTPApiCallBack )callback;

- (id)initWithRequest:(NSURLRequest *)request callback: ( JSonHTTPApiCallBack )callback;
- (id)initWithURL:(NSString *)url params:(NSDictionary * )params
         callback: ( JSonHTTPApiCallBack )callback;
-(void)cancel;

-(NSMutableURLRequest *)prepareRequest:(NSURLRequest *)request;

@end
