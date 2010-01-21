//
//  ExtractURL.m
//  KATG.com
//
//  Copyright 2009 Doug Russell
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

#import "ExtractURL.h"
#import "RegexKitLite.h"

@implementation ExtractURL

//*******************************************************
//* init
//* 
//* Set up object
//*******************************************************
- (id)init 
{
    if (self = [super init]) 
	{
		
    }
    return self;
}
//*******************************************************
//* newURLList:(NSString *)stringWithURLs
//* 
//* Create an array of URL strings
//* using regular expressions
//*******************************************************
- (id)newURLList:(NSString *)stringWithURLs 
{
	NSMutableArray *urlList = [[NSMutableArray alloc] initWithCapacity:12];
	NSMutableDictionary *urlDict;
	urlDict = [self makeURL:stringWithURLs];
	if (urlDict) 
	{
		NSString *protocolString = [urlDict objectForKey:@"protocol"];
		NSString *hostString = [urlDict objectForKey:@"host"];
		NSString *pathString = [urlDict objectForKey:@"path"];
		NSString *url = [protocolString stringByAppendingString:hostString]; 
		if (pathString != nil) {
			url = [url stringByAppendingString:pathString];
		}
		
		[urlList addObject:url];
	}
	int offset = 0;
	while (urlDict) 
	{
		offset += [[urlDict objectForKey:@"location"] intValue] + [[urlDict objectForKey:@"length"] intValue] - 1;
		int length = stringWithURLs.length - offset;
		urlDict = [self makeURL:[stringWithURLs substringWithRange:NSMakeRange( offset, length ) ]];		
		if (urlDict != nil) 
		{
			NSString *protocolString = [urlDict objectForKey:@"protocol"];
			NSString *hostString = [urlDict objectForKey:@"host"];
			NSString *pathString = [urlDict objectForKey:@"path"];
			NSString *url = [protocolString stringByAppendingString:hostString]; 
			if (pathString != nil) 
			{
				url = [url stringByAppendingString:pathString];
			}
			[urlList addObject:url];
		}
	}
	return urlList;
}
//*******************************************************
//* makeURL:(NSString *)searchString
//* 
//* Create a dictionary with the components
//* of first URL encountered in string
//*******************************************************
- (id)makeURL:(NSString *)searchString 
{
	NSString *regexString = @"\\b(https?://)(?:(\\S+?)(?::(\\S+?))?@)?([a-zA-Z0-9\\-.]+)(?::(\\d+))?((?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
	NSMutableDictionary *urlDictionary = [NSMutableDictionary dictionary];
	NSRange matchedRange;
	
	if ([searchString isMatchedByRegex:regexString]) 
	{
		matchedRange = [searchString rangeOfRegex:regexString];
		int Location = matchedRange.location;
		int Length = matchedRange.length;
		NSNumber *location = [[NSNumber alloc] initWithInt:Location];
		NSNumber *length = [[NSNumber alloc] initWithInt:Length];
		NSString *protocolString = [searchString stringByMatching:regexString capture:1L];
		NSString *hostString = [searchString stringByMatching:regexString capture:4L];
		NSString *pathString = [searchString stringByMatching:regexString capture:6L];
		
		regexString = @"\\.$|\\?$|\\!$";
		matchedRange = [pathString rangeOfRegex:regexString];
		if (matchedRange.location != NSNotFound) {
			pathString = [pathString substringWithRange:NSMakeRange(0, pathString.length - 1)];
		}
		
		if (location)       {[urlDictionary setObject:location forKey:@"location"];}
		if (length)         {[urlDictionary setObject:length forKey:@"length"];}
		if (protocolString) {[urlDictionary setObject:protocolString forKey:@"protocol"];} 
		if (hostString)     {[urlDictionary setObject:hostString forKey:@"host"];}
		if (pathString)     {[urlDictionary setObject:pathString forKey:@"path"];}
		
		[location release];
		[length release];
		
		return urlDictionary;
	} 
	else 
	{
		return nil;
	}
}
//*******************************************************
//* newTWTList:(NSString *)stringWithTWTs
//* 
//* Create an array of Twitter handles
//* using regular expressions
//*******************************************************
- (id)newTWTList:(NSString *)stringWithTWTs 
{
	NSMutableArray *twtList = [[NSMutableArray alloc] initWithCapacity:12];
	NSMutableDictionary *twtDict;
	
	twtDict = [self makeTwitterSearchURL:stringWithTWTs];
	if (twtDict != nil) 
	{
		[twtList addObject:[twtDict objectForKey:@"user"]];
	}
	
	int offset = 0;
	while (twtDict) 
	{
		offset += [[twtDict objectForKey:@"location"] intValue] + [[twtDict objectForKey:@"length"] intValue] - 1;
		int length = stringWithTWTs.length - offset;
		twtDict = [self makeTwitterSearchURL:[stringWithTWTs substringWithRange:NSMakeRange( offset, length ) ]];		
		if (twtDict) 
		{
			[twtList addObject:[twtDict objectForKey:@"user"]];
		}
	}
	
	return twtList;
}
//*******************************************************
//* makeTwitterSearchURL:(NSString *)searchString
//* 
//* Extract, using regular expressions,
//* the first twitter user name that
//* occurs in a string
//* Results are compiled in a dictionary as
//* the the Twitter handle and the location
//* in the string
//*******************************************************
- (id)makeTwitterSearchURL:(NSString *)searchString {
	NSString *regexString = @"@([0-9a-zA-Z_]+)";
	NSMutableDictionary *urlDictionary = [NSMutableDictionary dictionary];
	NSRange matchedRange;
	
	if ([searchString isMatchedByRegex:regexString]) {
		matchedRange = [searchString rangeOfRegex:regexString];
		int Location = matchedRange.location;
		int Length = matchedRange.length;
		NSNumber *location = [[NSNumber alloc] initWithInt:Location];
		NSNumber *length = [[NSNumber alloc] initWithInt:Length];
		NSString *twtUser = [searchString stringByMatching:regexString capture:1L];
		
		if (location)         {[urlDictionary setObject:location forKey:@"location"];}
		if (length)           {[urlDictionary setObject:length forKey:@"length"];}
		if (twtUser)          {[urlDictionary setObject:twtUser forKey:@"user"];} 
		
		[location release];
		[length release];
		
		return urlDictionary;
	} else {
		return nil;
	}
}

@end
