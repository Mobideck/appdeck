//
//  MPAdBrowserController.h
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef CF_RETURNS_RETAINED
#if __has_feature(attribute_cf_returns_retained)
#define CF_RETURNS_RETAINED __attribute__((cf_returns_retained))
#else
#define CF_RETURNS_RETAINED
#endif
#endif

@protocol MPAdBrowserControllerDelegateMF;

@interface MPAdBrowserControllerMF : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *safariButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *spinnerItem;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;

@property (nonatomic, assign) id<MPAdBrowserControllerDelegateMF> delegate;
@property (nonatomic, copy) NSURL *URL;

- (id)initWithURL:(NSURL *)URL HTMLString:(NSString *)HTMLString delegate:(id<MPAdBrowserControllerDelegateMF>)delegate;

// Navigation methods.
- (IBAction)back;
- (IBAction)forward;
- (IBAction)refresh;
- (IBAction)safari;
- (IBAction)done;

// Drawing methods.
- (CGContextRef)createContext CF_RETURNS_RETAINED;
- (UIImage *)backArrowImage;
- (UIImage *)forwardArrowImage;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPAdBrowserControllerDelegateMF <NSObject>

- (void)dismissBrowserController:(MPAdBrowserControllerMF *)browserController animated:(BOOL)animated;

@end
