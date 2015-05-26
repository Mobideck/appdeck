#import "MobFoxToolBar.h"

@implementation MobFoxToolBar

@synthesize backgroundImage;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    if (self.backgroundImage) {
        [backgroundImage drawInRect: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ];
    } else {
        [super drawRect:rect];
    }

}

@end
