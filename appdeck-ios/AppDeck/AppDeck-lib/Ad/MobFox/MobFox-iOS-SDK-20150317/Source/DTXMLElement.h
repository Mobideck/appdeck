#import <Foundation/Foundation.h>

@interface DTXMLElement : NSObject {
	NSString *name;
	NSMutableString *text;
	NSMutableArray *children;
	NSMutableDictionary *attributes;
	__unsafe_unretained DTXMLElement *parent;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableString *text;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) NSMutableDictionary *attributes;
@property (nonatomic, assign) __unsafe_unretained DTXMLElement *parent;

- (id) initWithName:(NSString *)elementName;
- (DTXMLElement *) getNamedChild:(NSString *)childName;
- (NSArray *) getNamedChildren:(NSString *)childName;
- (void) removeNamedChild:(NSString *)childName;
- (void) changeTextForNamedChild:(NSString *)childName toText:(NSString *)newText;
- (DTXMLElement *) addChildWithName:(NSString *)childName text:(NSString *)childText;

@property (unsafe_unretained, nonatomic, readonly) NSString *title;
@property (unsafe_unretained, nonatomic, readonly) NSURL *link;
@property (unsafe_unretained, nonatomic, readonly) NSString *content;

@end
