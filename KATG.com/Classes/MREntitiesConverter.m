//
//  MREntitiesConverter.m
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

#import "MREntitiesConverter.h"


@implementation MREntitiesConverter

@synthesize resultString;

- (id)init
{
    if([super init]) {
        resultString = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)s {
	[self.resultString appendString:s];
}

- (NSString*)convertEntitiesInString:(NSString*)s {
    if(s == nil) {
        NSLog(@"ERROR : Parameter string is nil");
    }
    NSString *xmlStr = [NSString stringWithFormat:@"<d>%@</d>", s];
    NSData *data = [xmlStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSXMLParser* xmlParse = [[NSXMLParser alloc] initWithData:data];
    [xmlParse setDelegate:self];
    [xmlParse parse];
    NSString* returnStr = [NSString stringWithFormat:@"%@", resultString];
	[xmlParse release];
    return returnStr;
}

- (void)dealloc {
    [resultString release];
    [super dealloc];
}

@end
