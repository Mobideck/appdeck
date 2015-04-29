#import "DTXMLElement.h"

@implementation DTXMLElement

@synthesize name, text, children, attributes, parent;

- (id) initWithName:(NSString *)elementName
{
	if (self = [super init])
	{
		self.name = elementName; 
		self.text = [NSMutableString string];

	}
	return self;
}

- (NSString *)description
{
	NSMutableString *attributeString = [NSMutableString string];
	for (NSString *oneAttribute in [attributes allKeys])
	{
		[attributeString appendFormat:@" %@=\"%@\"", oneAttribute, [[attributes objectForKey:oneAttribute] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
	}
	if ([children count])
	{
		NSMutableString *childrenString = [NSMutableString string];

		for (DTXMLElement *oneChild in children)
		{
			[childrenString appendFormat:@"%@", oneChild];
		}

		return [NSString stringWithFormat:@"<%@%@>%@</%@>", name, attributeString, childrenString, name];
	}
	else {
		return [NSString stringWithFormat:@"<%@%@>%@</%@>", name, attributeString, text, name];
	}
}

- (DTXMLElement *) getNamedChild:(NSString *)childName
{
	for (DTXMLElement *oneChild in self.children)
	{
		if ([oneChild.name isEqualToString:childName])
		{
			return oneChild;
		}
	}
	return nil;
}

- (NSArray *) getNamedChildren:(NSString *)childName
{
	NSMutableArray *tmpArray = [NSMutableArray array];
	for (DTXMLElement *oneChild in self.children)
	{
		if ([oneChild.name isEqualToString:childName])
		{
			[tmpArray addObject:oneChild];
		}
	}
	return [NSArray arrayWithArray:tmpArray];
}

- (void) removeNamedChild:(NSString *)childName
{
	DTXMLElement *childToDelete = [self getNamedChild:childName];
	[self.children removeObject:childToDelete];
}

- (void) changeTextForNamedChild:(NSString *)childName toText:(NSString *)newText
{
	DTXMLElement *childToModify = [self getNamedChild:childName];
	[childToModify.text setString:newText];
}

- (DTXMLElement *) addChildWithName:(NSString *)childName text:(NSString *)childText
{
	DTXMLElement *newChild = [[DTXMLElement alloc] initWithName:childName];
	if (childText)
	{
		newChild.text = [NSString stringWithString:childText];
	}
	newChild.parent = self;
	[self.children addObject:newChild];
	return newChild;
}

#pragma mark virtual properties
- (NSString *)title
{
	DTXMLElement *titleElement = [self getNamedChild:@"title"];
	return titleElement.text;
}

- (NSMutableDictionary *) attributes
{
	if (!attributes)
	{
		self.attributes = [NSMutableDictionary dictionary];
	}
	return attributes;
}

- (NSMutableArray *) children
{
	if (!children)
	{
		self.children = [NSMutableArray array];
	}
	return children;
}

- (NSURL *)link
{
	DTXMLElement *linkElement = [self getNamedChild:@"link"];
	NSString *linkString = [linkElement.attributes objectForKey:@"href"];

	return linkString?[NSURL URLWithString:linkString]:nil;
}

- (NSString *) content
{
	return [self valueForKey:@"content"];
}

- (id) valueForKey:(NSString *)key
{
	DTXMLElement *titleElement = [self getNamedChild:key];
	return titleElement.text;
}

@end
