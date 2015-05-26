//
//  MobFoxVASTRequest.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 18.05.2015.
//
//

#import <UIKit/UIKit.h>

@protocol MobFoxVASTRequestManagerDelegate <NSObject>

- (NSString *)publisherIdForMobFoxVASTRequest;

- (void)mobfoxDidReveiveVASTResponse:(NSString*)vastString;

@optional

- (void)mobfoxVASTRequestDidFailWithError:(NSError*)error;

@end

@interface MobFoxVASTRequestManager : NSObject

@property (nonatomic, assign) IBOutlet __unsafe_unretained id <MobFoxVASTRequestManagerDelegate> delegate;

@property (nonatomic, readonly, getter=isAdvertLoaded) BOOL advertLoaded;
@property (nonatomic, readonly, getter=isAdvertViewActionInProgress) BOOL advertViewActionInProgress;

@property (nonatomic, assign) BOOL locationAwareAdverts;
@property (nonatomic, assign) BOOL mraidSupported;
@property (nonatomic, assign) NSInteger video_min_duration;
@property (nonatomic, assign) NSInteger video_max_duration;

@property (nonatomic, assign) NSInteger userAge;
@property (nonatomic, strong) NSString* userGender;
@property (nonatomic, retain) NSArray* keywords;

-(void)requestVAST;

-(void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude;

@end
