//
//  VASTXMLParser.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 11.02.2014.
//
//

#import <Foundation/Foundation.h>
#import "DTXMLElement.h"
#import "VAST.h"

@interface VASTXMLParser : NSObject

+(NSMutableArray*) parseVAST:(DTXMLElement*) vastElement;

@end
