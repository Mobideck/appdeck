#import <UIKit/UIKit.h>

@interface UIView (FindViewController)

- (UIViewController *) firstAvailableUIViewController;
- (id) traverseResponderChainForUIViewController;

@end

// this makes the -all_load linker flag unnecessary, -ObjC still needed
@interface DummyView : UIView

@end