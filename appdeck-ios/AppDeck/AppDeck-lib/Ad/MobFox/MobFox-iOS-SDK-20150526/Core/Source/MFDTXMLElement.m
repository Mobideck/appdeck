#import "MFDTXMLElement.h"

@implementation MFDTXMLElement

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

		for (MFDTXMLElement *oneChild in children)
		{
			[childrenString appendFormat:@"%@", oneChild];
		}

		return [NSString stringWithFormat:@"<%@%@>%@</%@>", name, attributeString, childrenString, name];
	}
	else {
		return [NSString stringWithFormat:@"<%@%@>%@</%@>", name, attributeString, text, name];
	}
}

- (MFDTXMLElement *) getNamedChild:(NSString *)childName
{
	for (MFDTXMLElement *oneChild in self.children)
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
	for (MFDTXMLElement *oneChild in self.children)
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
	MFDTXMLElement *childToDelete = [self getNamedChild:childName];
	[self.children removeObject:childToDelete];
}

- (void) changeTextForNamedChild:(NSString *)childName toText:(NSString *)newText
{
	MFDTXMLElement *childToModify = [self getNamedChild:childName];
	[childToModify.text setString:newText];
}

- (MFDTXMLElement *) addChildWithName:(NSString *)childName text:(NSString *)childText
{
	MFDTXMLElement *newChild = [[MFDTXMLElement alloc] initWithName:childName];
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
	MFDTXMLElement *titleElement = [self getNamedChild:@"title"];
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
	MFDTXMLElement *linkElement = [self getNamedChild:@"link"];
	NSString *linkString = [linkElement.attributes objectForKey:@"href"];

	return linkString?[NSURL URLWithString:linkString]:nil;
}

- (NSString *) content
{
	return [self valueForKey:@"content"];
}

- (id) valueForKey:(NSString *)key
{
	MFDTXMLElement *titleElement = [self getNamedChild:key];
	return titleElement.text;
}

@end
