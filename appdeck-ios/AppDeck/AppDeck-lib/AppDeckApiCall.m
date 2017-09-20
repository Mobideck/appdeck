//
//  AppDeckApiCall.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 14/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeckApiCall.h"
#import "NSError+errorWithFormat.h"
//#import "JSONKit.h"
#import "IOSVersion.h"
#import "AppDeck.h"
#import "ManagedWebView.h"

@implementation AppDeckApiCall

-(id)init
{
    _resultJSON = @"[\"\"]";
    return self;
}

-(void)sendCallBackWithType:(NSString *)type params:(NSArray *)params
{
    if (self.eventID == nil)
        return;
    NSDictionary *eventDic = @{@"detail": @{@"type": type, @"params" : params}};
    NSError *error;
    NSData *eventData = nil;
    @try {
        eventData = [NSJSONSerialization dataWithJSONObject:eventDic options:NSJSONWritingPrettyPrinted error:&error];
        //retData = [retArray JSONDataWithOptions:JKSerializeOptionPretty|JKSerializeOptionEscapeUnicode error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"JSAPI: Event: Exception while writing JSon: %@: %@", exception, params);
        return;
    }
    
    if (error != nil)
    {
        NSLog(@"JSAPI: Event: Error while writing JSon: %@: %@", error, params);
    }
    
    NSString *eventJson = [[NSString alloc] initWithData:eventData encoding:NSUTF8StringEncoding];
    
    NSString *js = nil;
    AppDeck *appDeck = [AppDeck sharedInstance];
    if (appDeck.iosVersion >= 6.0)
    {
        js = [NSString stringWithFormat:@"document.dispatchEvent(new CustomEvent('%@', %@));", self.eventID, eventJson];
        //    NSString *js = [NSString stringWithFormat:@"var e = new CustomEvent('%@', %@); setTimeout(\"document.dispatchEvent(e)\", 0);", self.eventID, eventJson];
        [self.managedWebView executeJS:js];
    } else {
        js = [NSString stringWithFormat:@"var evt = document.createEvent('Event');evt.initEvent('%@',true,true); evt.detail = %@; document.dispatchEvent(evt);", self.eventID, eventJson];
        //    NSString *js = [NSString stringWithFormat:@"var e = new CustomEvent('%@', %@); setTimeout(\"document.dispatchEvent(e)\", 0);", self.eventID, eventJson];   
    }
//    js = [NSString stringWithFormat:@"setTimeout(function(){%@}, 150);", js];
//    [self.webview performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
    [self.managedWebView executeJS:js];
}

-(void)sendCallBackWithErrorMessage:(NSString *)errorMessage
{
    self.callBackSend = YES;
    [self sendCallBackWithType:@"error" params:@[errorMessage]];
}

-(void)sendCallBackWithError:(NSError *)error
{
    self.callBackSend = YES;
    [self sendCallBackWithType:@"error" params:@[error.description]];
}

-(void)sendCallbackWithResult:(NSArray *)result
{
    self.callBackSend = YES;
    [self sendCallBackWithType:@"success" params:result];
}

-(void)sendRepeatingCallback:(NSArray *)result
{
    self.callBackSend = YES;
    [self sendCallBackWithType:@"callback" params:result];
}


-(void)dealloc
{
    if (self.callBackSend == NO)
    {
        [self sendCallBackWithType:@"cancel" params:@[]];
    }
}

#pragma mark param

-(id)input
{
    if (_input == nil && _inputJSON != nil)
    {
        // STEP 1 : Read Input
        NSError *error = nil;
        NSData *inputJSONData = [_inputJSON dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *tmpinput = nil;
        @try {
            tmpinput = [NSJSONSerialization JSONObjectWithData:inputJSONData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
            //tmpinput = [inputJSONData objectFromJSONDataWithParseOptions:JKParseOptionComments|JKParseOptionUnicodeNewlines|JKParseOptionLooseUnicode|JKParseOptionPermitTextAfterValidJSON error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"JSAPI: input: Exception while reading JSon: %@: %@", exception, _inputJSON);
            return nil;
        }
        
        if (error != nil)
        {
            NSLog(@"JSAPI: input: Error while reading JSon: %@: %@", error, _inputJSON);
            return nil;
        }
        
        if ([[tmpinput class] isSubclassOfClass:[NSDictionary class]] == NO)
        {
            NSLog(@"JSAPI: input: invalid input format: not an object: %@", _inputJSON);
            return nil;
        }
        
        _input = tmpinput;
    }
    return _input;
}

-(id)param
{
    if (_param == nil)
    {
        _param = [self.input objectForKey:@"param"];
    }
    return _param;
}

-(void)setResult:(id)result
{
    NSError *error;
    NSString *resultJson = nil;
    
/*    if (result == nil || [[result class] isSubclassOfClass:[NSNull class]])
    {
        resultJson = @"null";
    }
    else if ([[result class] isSubclassOfClass:[NSString class]])
    {
        resultJson = [NSString stringWithFormat:@"\"%@\"", [result stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
    }
    else if ([[result class] isSubclassOfClass:[NSNumber class]])
    {
        resultJson = [NSString stringWithFormat:@"%@", result];
    }
    else
    {*/
        @try {
            NSData *resultJSONData = [NSJSONSerialization dataWithJSONObject:@[result] options:NSJSONWritingPrettyPrinted error:&error];
            if (error != nil)
            {
                NSLog(@"JSAPI: setResult: Error while writing JSon: %@: %@", error, result);
                resultJson = @"null";
            }
            resultJson = [[NSString alloc] initWithData:resultJSONData encoding:NSUTF8StringEncoding];
        }
        @catch (NSException *exception) {
            NSLog(@"JSAPI: setResult: Exception while writing JSon: %@: %@", exception, result);
        }

    //}
    
    _result = result;
    _resultJSON = resultJson;
}

-(NSString *)eventID
{
    if (_eventID == nil)
        _eventID = [self.input objectForKey:@"eventid"];
    return _eventID;
}

-(NSString *)jsTarget
{
    return [NSString stringWithFormat:@"app.apicall_els['%@']", self.eventID];
}

@end
