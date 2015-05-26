//
//  CJSONSerializedData.m
//  TouchJSON
//
//  Created by Jonathan Wight on 10/31/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "MFCJSONSerializedData.h"

@interface MFCJSONSerializedData ()
@end

#pragma mark -

@implementation MFCJSONSerializedData

@synthesize data;

- (id)initWithData:(NSData *)inData
    {
    if ((self = [super init]) != NULL)
        {
        data = [inData retain];
        }
    return(self);
    }

- (void)dealloc
    {
    [data release];
    data = NULL;
    //
    [super dealloc];
    }

- (NSData *)serializedJSONData
    {
    return(self.data);
    }

@end
