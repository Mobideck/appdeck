//
//  IMUtilities.m
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import "IMUtilities.h"
#import "IMGlobalImageCache.h"
@implementation IMUtilities


+(NSDictionary*)newsDictFromNativeContent:(NSString*)nativeContent {
    
    if (nativeContent==nil) {
        return nil;
    }
    NSData* data = [nativeContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSMutableDictionary* nativeJsonDict = [NSMutableDictionary dictionaryWithDictionary:jsonDict];
    if (error == nil && nativeJsonDict != nil) {
        [nativeJsonDict setValue:[NSNumber numberWithBool:YES] forKey:@"isAd"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            
            NSDictionary* imageDict = [nativeJsonDict valueForKey:@"icon"];
            
            NSString* url = [imageDict valueForKey:@"url"];
            
            NSURL* imgURL = [NSURL URLWithString:url];
            
            NSData* rawImgdata = [NSData dataWithContentsOfURL:imgURL];
            UIImage* image = [UIImage imageWithData:rawImgdata];
            IMGlobalImageCache* cache = [IMGlobalImageCache sharedCache];
            [cache addImage:image forKey:url];
        });
    }
    return nativeJsonDict;
}

+(NSDictionary*)boardDictFromNativeContent:(NSString*)nativeContent {
    return [self newsDictFromNativeContent:nativeContent];
}

+(NSURL*)getImageURLFromNewsDict:(NSDictionary*)dict {
    NSURL* imageURL = nil;
    
    if (dict == nil) {
        return imageURL;
    }
    
    NSArray* mediaGroups = [dict valueForKey:@"mediaGroups"];
    
    if (mediaGroups == nil || [mediaGroups count] == 0) {
        return imageURL;
    }
    
    NSDictionary* contents = [mediaGroups objectAtIndex:0];
    if (contents == nil) {
        return imageURL;
    }
    
    NSArray* contentsArray = [contents valueForKey:@"contents"];
    if (contentsArray == nil || [contentsArray count]==0) {
        return imageURL;
    }
    
    NSDictionary* values = [contentsArray objectAtIndex:0];
    if (values == nil) {
        return imageURL;
    }
    
    imageURL = [NSURL URLWithString:[values valueForKey:@"url"]];
    
    return imageURL;
}

+(NSArray*)newsItemsFromJsonDict:(NSDictionary*)jsonDict {
    NSMutableArray* array = nil;
    
    if (jsonDict == nil) {
        return array;
    }
    
    NSDictionary* responseData = [jsonDict valueForKey:@"responseData"];
    if (responseData == nil) {
        return array;
    }
    NSDictionary* feed = [responseData valueForKey:@"feed"];
    if (feed == nil) {
        return array;
    }
    NSArray* itemsArray = [NSMutableArray arrayWithArray:[feed valueForKey:@"entries"]];
    if (itemsArray == nil || [itemsArray count] == 0) {
        return itemsArray;
    }
    array = [NSMutableArray array];
    for (NSDictionary* item in itemsArray) {
        NSArray* mediaGroupsArray = [item valueForKey:@"mediaGroups"];
        if (mediaGroupsArray!=nil) {
            [array addObject:item];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                NSURL* imgURL = [self getImageURLFromNewsDict:item];
                
                NSData* imageData = [NSData dataWithContentsOfURL:imgURL];
                UIImage* image = [UIImage imageWithData:imageData];
                NSString* imageUrl = [imgURL absoluteString];
                
                [[IMGlobalImageCache sharedCache] addImage:image forKey:imageUrl];
                
                //Broadcast a notification saying that an image has been loaded for a particular url
                
                [[NSNotificationCenter defaultCenter] postNotificationName:URL_LOADED_NOTIFICATION object:imageUrl];
                
            });
        }
    }
    
    return array;
}

+(NSArray*)boardItemsFromJsonDict:(NSDictionary*)jsonDict {
    return [self newsItemsFromJsonDict:jsonDict];
}

+(NSURL*)getImageURLFromBoardDict:(NSDictionary*)dict {
    return [self getImageURLFromNewsDict:dict];
}

@end
