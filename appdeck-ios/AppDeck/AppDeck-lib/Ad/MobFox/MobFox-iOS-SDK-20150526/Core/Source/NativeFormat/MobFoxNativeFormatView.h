//
//  MobFoxNativeFormatView.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 20.04.2015.
//
//

#import <UIKit/UIKit.h>
#import "MobFoxNativeFormatCreative.h"

@class MobFoxNativeFormatView;

@protocol MobFoxNativeFormatViewDelegate <NSObject>

- (void)mobfoxNativeFormatDidLoad:(MobFoxNativeFormatView *)nativeFormatView;

- (void)mobfoxNativeFormatDidFailToLoadWithError:(NSError *)error;

@optional

- (void)mobfoxNativeFormatWillPresent;

- (void)mobfoxNativeFormatActionWillFinish;

- (void)mobfoxNativeFormatActionDidFinish;

@end


@interface MobFoxNativeFormatView : UIView

@property (nonatomic, assign) IBOutlet __unsafe_unretained id <MobFoxNativeFormatViewDelegate> delegate;

-(void)requestAdWithCreative:(MobFoxNativeFormatCreative*)creative andPublisherId:(NSString*)publisherId;

@end
