//
//  IMBaseViewController.h
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMNative.h"
#import "IMAppIds.h"


#define IMG_TAG 0xAB
#define TITLE_TAG 0xCD
#define DESCRIPTION_TAG 0xEF
#define SPONSERED_LABEL_TAG 0x89

#define RGBToUIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface IMBaseViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) UILabel* statusLabel;
@property (nonatomic, strong) NSMutableData* responseData;
@property NSUInteger requstStatusCode;
@property (nonatomic, strong) IMNative* native;
@property (nonatomic, strong) NSString* nativeContent;
@property (nonatomic, strong) NSMutableArray* items;

-(void)loadNativeAd; // should be implemented by sublcasses. Load the native ad and add the content to nativeContent so that its available.

-(NSString*)serverUrl; // should be implemented by subclasses

-(NSArray*)itemsFromJsonDict:(NSDictionary*)jsonDict; // should be implemented by subclasses

-(void)attachNativeAdToView:(UIView*)view; // should be implemented by subclasses

-(NSDictionary*)dictFromNativeContent;  // should be implemented by subclasses

-(NSUInteger)widthtOfCellForCurrentOrientation; // should be implemented by subclasses

-(NSUInteger)heightOfCellForCurrentOrientation; // should be implemented by subclasses

-(CGRect)frameForCellAtCurrentOrientation; // should be implemented by subclasses


@end

