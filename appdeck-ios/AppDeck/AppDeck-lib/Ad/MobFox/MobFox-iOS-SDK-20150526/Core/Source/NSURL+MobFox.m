#import "NSURL+MobFox.h"

@implementation NSURL (MobFox)

- (BOOL)isDeviceSupported
{
	NSString *scheme = [self scheme];
	NSString *host = [self host];
	if ([scheme isEqualToString:@"tel"] || [scheme isEqualToString:@"sms"] || [scheme isEqualToString:@"mailto"])
	{
		return YES;
	}
	if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])
	{
		if ([host isEqualToString:@"maps.google.com"])
		{
			return YES;
		}

		if ([host isEqualToString:@"www.youtube.com"])
		{
			return YES;
		}

		if ([host isEqualToString:@"phobos.apple.com"])
		{
			return YES;
		}
        
        if ([host hasSuffix:@"itunes.apple.com"])
		{
			return YES;
		}
        
	}
    if (([scheme isEqualToString:@"itms-apps"] && [host hasSuffix:@"itunes.apple.com"]) || ([scheme isEqualToString:@"itms-appss"] && [host hasSuffix:@"itunes.apple.com"]))
    {
        return YES;
    }
	return NO;	
}

@end

@implementation DummyURL

@end
