//
//  RE2Regexp.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 29/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "RE2Regexp.h"

#include "re2/re2.h"
using namespace re2;
@interface RE2Regexp ()
{
    RE2    *re;
    NSString *regexString;
}

@end

@implementation RE2Regexp

-(id)initWithString:(NSString *)_regexString
{
    regexString = _regexString;
    RE2::Options opt;
    opt.set_never_nl(true);
    const char *string = [regexString cStringUsingEncoding:NSUTF8StringEncoding];
    re = new RE2(string, opt);
    if (re->ok() == 0)
        return nil;
    return self;
}

-(BOOL)match:(const char *)text
{
    int res = RE2::PartialMatch(text, *re);

#ifdef DEBUG_OUTPUT
    //NSLog(@"regexp: %s match %@ ? %d", text, regexString, res);
#endif
    return res;
    //assert(RE2::PartialMatch(text, re));
/*
    int i;
    string s;
    RE2 re([regexString UTF8String]);
    assert(re.ok());
    
    int res = RE2::FullMatch([str UTF8String], re, &s, &i);
    
    NSLog(@"regexp: %@ match %@ ? %d %d", str, regexString, res, i);
    
    return res == 1;*/
}

@end
