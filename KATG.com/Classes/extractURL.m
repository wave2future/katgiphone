//
//  extractURL.m
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

#import "extractURL.h"
#import "RegexKitLite.h"


@implementation extractURL

//*******************************************************
//* init
//* 
//* Set up object
//*******************************************************
- (id)init {
	return self;
}

//*******************************************************
//* makeURLList:(NSString *)stringWithURLs
//* 
//* Create an array of URL strings
//*******************************************************
- (id)makeURLList:(NSString *)stringWithURLs {
	NSMutableArray *urlList = [[NSMutableArray alloc] initWithCapacity:12];
	NSMutableDictionary *urlDict = [NSMutableDictionary dictionary];
	
	urlDict = [self makeURL:stringWithURLs];
	if (urlDict != nil) {
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
	while (urlDict != nil) {
		offset += [[urlDict objectForKey:@"location"] intValue] + [[urlDict objectForKey:@"length"] intValue] - 1;
		int length = stringWithURLs.length - offset;
		urlDict = [self makeURL:[stringWithURLs substringWithRange:NSMakeRange( offset, length ) ]];		
		if (urlDict != nil) {
			NSString *protocolString = [urlDict objectForKey:@"protocol"];
			NSString *hostString = [urlDict objectForKey:@"host"];
			NSString *pathString = [urlDict objectForKey:@"path"];
			NSString *url = [protocolString stringByAppendingString:hostString]; 
			if (pathString != nil) {
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
//* Create an array of tweet user dictionaries
//*******************************************************
- (id)makeURL:(NSString *)searchString {
	NSString *regexString = @"\\b(https?://)(?:(\\S+?)(?::(\\S+?))?@)?([a-zA-Z0-9\\-.]+)(?::(\\d+))?((?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
	NSMutableDictionary *urlDictionary = [NSMutableDictionary dictionary];
	NSRange matchedRange = NSMakeRange(NSNotFound, 0UL); 
	
	if ([searchString isMatchedByRegex:regexString]) {
		matchedRange = [searchString rangeOfRegex:regexString];
		int Location = matchedRange.location;
		int Length = matchedRange.length;
		NSNumber *location = [[NSNumber alloc] initWithInt:Location];
		NSNumber *length = [[NSNumber alloc] initWithInt:Length];
		NSString *protocolString = [searchString stringByMatching:regexString capture:1L];
		//NSString *userString = [searchString stringByMatching:regexString capture:2L];
		//NSString *passwordString = [searchString stringByMatching:regexString capture:3L];
		NSString *hostString = [searchString stringByMatching:regexString capture:4L];
		//NSString *portString = [searchString stringByMatching:regexString capture:5L];
		NSString *pathString = [searchString stringByMatching:regexString capture:6L];
		
		regexString = @"\\.$|\\?$|\\!$";
		matchedRange = NSMakeRange(NSNotFound, 0UL);
		matchedRange = [pathString rangeOfRegex:regexString];
		if (matchedRange.location != NSNotFound) {
			pathString = [pathString substringWithRange:NSMakeRange(0, pathString.length - 1)];
		}
		
		if (location)       {[urlDictionary setObject:location forKey:@"location"];}
		if (length)         {[urlDictionary setObject:length forKey:@"length"];}
		if (protocolString) {[urlDictionary setObject:protocolString forKey:@"protocol"];} 
		//if (userString)     {[urlDictionary setObject:userString forKey:@"user"];} 
		//if (passwordString) {[urlDictionary setObject:passwordString forKey:@"password"];}
		if (hostString)     {[urlDictionary setObject:hostString forKey:@"host"];}
		//if (portString)     {[urlDictionary setObject:portString forKey:@"port"];}
		if (pathString)     {[urlDictionary setObject:pathString forKey:@"path"];}
		NSLog(@"urlDictionary: %@", urlDictionary);
		
		return urlDictionary;
	} else {
		return nil;
	}
}

//*******************************************************
//* makeTWTList:(NSString *)stringWithTWTs
//* 
//* Extract, using regular expressions,
//* the first URL that occurs in a string
//* Results are compiled in an array
//*******************************************************

- (id)makeTWTList:(NSString *)stringWithTWTs {
	NSMutableArray *twtList = [[NSMutableArray alloc] initWithCapacity:12];
	NSMutableDictionary *twtDict = [NSMutableDictionary dictionary];
	
	twtDict = [self makeTwitterSearchURL:stringWithTWTs];
	if (twtDict != nil) {
		NSMutableDictionary *url = [NSMutableDictionary dictionary];
		
		[url setObject:[twtDict objectForKey:@"user"] forKey:@"user"];
		[url setObject:[twtDict objectForKey:@"url"] forKey:@"url"];
		
		[twtList addObject:url];
	}
	
	int offset = 0;
	while (twtDict != nil) {
		offset += [[twtDict objectForKey:@"location"] intValue] + [[twtDict objectForKey:@"length"] intValue] - 1;
		int length = stringWithTWTs.length - offset;
		twtDict = [self makeTwitterSearchURL:[stringWithTWTs substringWithRange:NSMakeRange( offset, length ) ]];		
		if (twtDict != nil) {
			NSMutableDictionary *url = [NSMutableDictionary dictionary];
			
			[url setObject:[twtDict objectForKey:@"user"] forKey:@"user"];
			[url setObject:[twtDict objectForKey:@"url"] forKey:@"url"];
			
			[twtList addObject:url];
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
//* the the user name and the json library
//* URL
//*******************************************************
- (id)makeTwitterSearchURL:(NSString *)searchString {
	NSString *regexString = @"@([0-9a-zA-Z_]+)";
	NSMutableDictionary *urlDictionary = [NSMutableDictionary dictionary];
	NSRange matchedRange = NSMakeRange(NSNotFound, 0UL); 
	
	if ([searchString isMatchedByRegex:regexString]) {
		matchedRange = [searchString rangeOfRegex:regexString];
		int Location = matchedRange.location;
		int Length = matchedRange.length;
		NSNumber *location = [[NSNumber alloc] initWithInt:Location];
		NSNumber *length = [[NSNumber alloc] initWithInt:Length];
		NSString *twtUser = [searchString stringByMatching:regexString capture:1L];
		NSString *twtUserSearchUrl = @"http://search.twitter.com/search.json?q=from%3A";
		twtUserSearchUrl = [[twtUserSearchUrl stringByAppendingString:twtUser] stringByAppendingString:@"&rpp=10"];
		
		if (location)         {[urlDictionary setObject:location forKey:@"location"];}
		if (length)           {[urlDictionary setObject:length forKey:@"length"];}
		if (twtUser)          {[urlDictionary setObject:twtUser forKey:@"user"];} 
		if (twtUserSearchUrl) {[urlDictionary setObject:twtUserSearchUrl forKey:@"url"];} 

		NSLog(@"urlDictionary: %@", urlDictionary);
		
		return urlDictionary;
	} else {
		return nil;
	}
}

- (void)dealloc {
    [super dealloc];
}

@end
