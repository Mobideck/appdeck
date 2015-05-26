//
//  VASTXMLParser.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 11.02.2014.
//
//

#import <Foundation/Foundation.h>
#import "MFDTXMLElement.h"
#import "VAST.h"

@interface MFVASTXMLParser : NSObject

+(NSMutableArray*) parseVAST:(MFDTXMLElement*) vastElement;

@end
