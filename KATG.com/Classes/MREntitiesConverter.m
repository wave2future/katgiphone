//
//  MREntitiesConverter.m
//  KATG.com
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
    NSString* returnStr = [[NSString alloc] initWithFormat:@"%@", resultString];
	[xmlParse release];
    return returnStr;
}

- (void)dealloc {
    [resultString release];
    [super dealloc];
}

@end
