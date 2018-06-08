//
//  myView.h
//  AppDeck
//
//  Created by hanine ben saad on 07/06/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoaderChildViewController;
@interface myView : UIView

@property(nonatomic,retain) IBOutlet UILabel*title, *address;
@property(nonatomic,retain) IBOutlet UIImageView*imageView;


-(void)downloadImage:(NSString *)url inChild:(LoaderChildViewController*)child;

@end
