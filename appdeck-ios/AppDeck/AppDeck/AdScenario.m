//
//  AdScenario.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 04/09/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import "AdScenario.h"
#import "AdRation.h"

@implementation AdScenario


-(id)initWithPlacement:(AdPlacement *)adPlacement config:(NSDictionary *)config
{
    self = [self init];
    if (self)
    {
        self.adPlacement = adPlacement;
        self.config = config;
        [self loadConfiguration:self.config];
    }
    return self;
}

-(void)cancel
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    for (AdRation *adRation in self.rations)
    {
        [adRation cancel];
    }
    self.rations = nil;
}

-(void)dealloc
{
    [self cancel];
}

-(BOOL)loadConfiguration:(NSDictionary *)config
{
    // rules
    self.rules = [config objectForKey:@"rules"];
    if (!self.rules || ![[self.rules class] isSubclassOfClass:[NSDictionary class]])
        self.rules = @{};
    self.ruleMaxWidth = [[self.rules objectForKey:@"maxWidth"] floatValue];
    self.ruleMaxHeight = [[self.rules objectForKey:@"maxHeight"] floatValue];

    // rations
    NSArray *rations = [config objectForKey:@"ads"];
    if (rations && [[rations class] isSubclassOfClass:[NSArray class]])
    {
        self.rations = [[NSMutableArray alloc] initWithCapacity:rations.count];
        for (NSDictionary *rationConfig in rations)
        {
            if (![[rationConfig class] isSubclassOfClass:[NSDictionary class]])
                continue;
            AdRation *adRation = [[AdRation alloc] initWithScenario:self config:rationConfig];
            [self.rations addObject:adRation];
        }
    }
 
    return YES;
}

-(BOOL)isValid
{
    CGRect pageSize = self.adPlacement.adRequest.page.view.bounds;
    
    // check width/height
    if (pageSize.size.width < self.ruleMaxWidth)
        return NO;
    if (pageSize.size.height < self.ruleMaxHeight)
        return NO;

    return YES;
}

-(BOOL)start
{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkAds:) userInfo:nil repeats:YES];
    return YES;
}

-(void)checkAds:(NSTimer *)timer
{
    // no more ration ?
    if (noMoreRation)
        return;
    
    // if final ration has been found
    if (currentAdRation != nil && currentAdRation.state == AdRationStateOk)
        return;
    
    // if a ration is running, wait
    else if (currentAdRation != nil && (currentAdRation.state == AdRationStateNew || currentAdRation.state == AdRationStateWorking))
        return;
    
    // if we must try next ration
    else if (currentAdRation != nil && currentAdRation.state == AdRationStateNext)
    {
        [backgroundAdRations addObject:currentAdRation];
        currentAdRation = nil;
    }
    
    // if we must try next ration
    else if (currentAdRation != nil && currentAdRation.state == AdRationStateFailed)
    {
        currentAdRation = nil;
    }
    
    // if no ration is currently running, try next one
    currentAdRation = [self getNextRation];
    if (currentAdRation != nil)
    {
        [currentAdRation start];
        return;
    }
    
    // if no ration is available
    // TODO: fetch more rations
}

-(AdRation *)getNextRation
{
    if (nextRationIdx >= self.rations.count)
        return nil;
    
    AdRation *adRation = [self.rations objectAtIndex:nextRationIdx];
    nextRationIdx++;
    
    return adRation;
}

@end


