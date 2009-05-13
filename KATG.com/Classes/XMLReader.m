//
//  XMLReader.m
//  KATG.com
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "XMLReader.h"
#import "Show.h"


static NSUInteger parsedNodesCounter;
static BOOL number;
static BOOL date;
static BOOL title;
static BOOL description;
static BOOL thread;
static BOOL file;
static BOOL detail;

@implementation XMLReader

@synthesize feedEntries, currentItem;

#define MAX_ITEMS 20

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    parsedNodesCounter = 0;
}

- (id)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error
{	
	feedEntries = [[NSMutableArray alloc] init];
	
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
	
    NSError *parseError = [parser parserError];
    if (parseError && error) {	
        *error = parseError;
    }
    
    [parser release];
	
	return feedEntries;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) {
        elementName = qName;
    }

    if (parsedNodesCounter >= MAX_ITEMS) {
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString:@"Show"]) {
        
        parsedNodesCounter++;
		
		if (currentItem) {
			currentItem = nil;
		}
		
		currentItem = [[NSMutableArray alloc] initWithCapacity:3];
		
		item = YES;
		title = NO;
		description = NO;
    }
        
    if ([elementName isEqualToString:@"enclosure"]) {
        NSString *relAtt = [attributeDict valueForKey:@"url"];
		NSLog(relAtt);
		[currentItem addObject:relAtt];
		item = NO;
		
		Show *sh = [[Show alloc] initWithTitle:[currentItem objectAtIndex:0] publishDate:(NSString *)@"April 15th" link:[currentItem objectAtIndex:2] detail:[currentItem objectAtIndex:1]];
		[feedEntries addObject:sh];
    } else if ([elementName isEqualToString:@"title"]) {
		NSLog(@"TITLE");
		title = YES;
    } else if ([elementName isEqualToString:@"description"]) {
		NSLog(@"description");
		description = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
    if (qName) {
        elementName = qName;
    }
    
    if ([elementName isEqualToString:@"title"]) {
        NSLog(@"TITLE");
		title = NO;
    } else if ([elementName isEqualToString:@"description"]) {
		NSLog(@"description");
		description = NO;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (currentItem) {
		if (title) {
			[currentItem addObject:string];
			title = NO;
		} else if (description) {
			[currentItem addObject:string];
			description = NO;
		}
	}
     NSLog(string);
}

@end
