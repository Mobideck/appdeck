//
//  CJSONSerialization.m
//  TouchJSON
//
//  Created by Jonathan Wight on 03/04/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "MFCJSONSerialization.h"

#import "MFCJSONDeserializer.h"
#import "MFCJSONSerializer.h"

@implementation MFCJSONSerialization

+ (BOOL)isValidJSONObject:(id)obj
    {
    MFCJSONSerializer *theSerializer = [MFCJSONSerializer serializer];
    return([theSerializer isValidJSONObject:obj]);
    }

+ (NSData *)dataWithJSONObject:(id)obj options:(EJSONWritingOptions)opt error:(NSError **)error
    {
    #pragma unused (opt)
    
    MFCJSONSerializer *theSerializer = [MFCJSONSerializer serializer];
    NSData *theData = [theSerializer serializeObject:obj error:error];
    return(theData);
    }

+ (id)JSONObjectWithData:(NSData *)data options:(EJSONReadingOptions)opt error:(NSError **)error
    {
    MFCJSONDeserializer *theDeserializer = [MFCJSONDeserializer deserializer];
    theDeserializer.options = (opt & kCJSONReadingMutableContainers ? 0 : kJSONDeserializationOptions_MutableContainers)
        | (opt & kCJSONReadingMutableLeaves ? 0 : kJSONDeserializationOptions_MutableLeaves);
    id theObject = [theDeserializer deserialize:data error:error];
    return(theObject);    
    }

+ (NSInteger)writeJSONObject:(id)obj toStream:(NSOutputStream *)stream options:(EJSONWritingOptions)opt error:(NSError **)error
    {
    // TODO -- this is a quick work around.
    NSInteger theSize = -1;
    NSData *theData = [self dataWithJSONObject:obj options:opt error:error];
    if (theData)
        {
        theSize = [stream write:[theData bytes] maxLength:[theData length]];
        }
    return(theSize);
    }

+ (id)JSONObjectWithStream:(NSInputStream *)stream options:(EJSONReadingOptions)opt error:(NSError **)error
    {
    #pragma unused (stream, opt, error)
    // TODO -- how much to read? Ugh.
    return(NULL);
    }

@end
