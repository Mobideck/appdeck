//
//  BarCodeScannerViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 04/09/2017.
//  Copyright © 2017 Mathieu De Kermadec. All rights reserved.
//

#import "LoaderChildViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface BarCodeScannerViewController : LoaderChildViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) BOOL isReading;

@property (nonatomic, strong) NSString *lastMatch;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (weak, nonatomic) IBOutlet UIView *preview;

@property (nonatomic, strong) AppDeckApiCall *origin;

-(void)stopReading;

@end
