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

@synthesize urlList;
@synthesize urlArray;
@synthesize urlAddress;

//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (id)init {
	urlList = [[NSMutableArray alloc] initWithCapacity:12];
	urlArray = [[NSMutableArray alloc] initWithCapacity:3];
	urlAddress = [[NSString alloc] init];
	return self;
}

//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (id)makeURLList:(NSString *)tweetString {
	NSMutableArray *temp1 = [self makeURL:tweetString];
	
	NSString *temp2 = [temp1 objectAtIndex:0];
	
	//[tweetString substringWithRange:NSMakeRange( urlStart, urlLength ) ];
	
	[urlList addObject:temp2];
	
	int temp5 = 0;
	
	while (urlAddress != nil) {
		temp5 += [[temp1 objectAtIndex:1] intValue] - 1;
		temp1 = [self makeURL:[tweetString substringWithRange:NSMakeRange( temp5, tweetString.length - temp5 ) ]];
		if (urlAddress != nil) {
			NSString *temp2 = [temp1 objectAtIndex:0];
			[urlList addObject:temp2];
		}
	}
	
	return urlList;
}

//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (id)makeURL:(NSString *)tweetString {
	NSString *searchString = @"This is neat. ahttp://Digg.com. http://google.com"; 
	NSString *regexString = @"\\b(?:[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}?[a-zA-Z0-9]\\.)+[a-zA-Z]{2,6}\\b"; 
	NSRange matchedRange = NSMakeRange(NSNotFound, 0UL); 
	NSError *error = NULL; 
	matchedRange = [searchString rangeOfRegex:regexString options:RKLNoOptions inRange:NSMakeRange(0, searchString.length) capture:1L error:&error]; 
	NSLog(@"matchedRange: %@", NSStringFromRange(matchedRange)); 
	NSString *matchedString = [searchString substringWithRange:matchedRange]; 
	NSLog(@"matchedString: '%@'", matchedString); 
	
	
	
	[urlArray removeAllObjects];
	int tweetLength = tweetString.length;
	int urlStart = 0;
	int urlLength = tweetLength;
	
	int a = tweetLength;
	int b = tweetLength;
	int c = tweetLength;
	int d = tweetLength;
	if ([tweetString rangeOfString: @"http:" options:1].location != NSNotFound) {
		a = [tweetString rangeOfString: @"http:" options:1].location;
	}
	if ([tweetString rangeOfString: @"www." options:1].location != NSNotFound) {
		b = [tweetString rangeOfString: @"www." options:1].location;
	}
	if ([tweetString rangeOfString: @".com" options:1].location != NSNotFound) {
		c = [tweetString rangeOfString: @".com" options:1].location;
	}
	if ([tweetString rangeOfString: @"@" options:1].location != NSNotFound) {
		d = [tweetString rangeOfString: @"@" options:1].location;
	}
	
	int min = a;
	int mode = 1;
	if ( b < min ) {
		min = b;
		mode = 2;
	}
	if( c < min ) {
		min = c;
		mode = 3;
	}
	if ( d < min ) {
		min = d;
		mode = 4;
	}
	
	if (min == tweetLength) {
		mode = 0;
	}
	
	if ( mode == 1 ) {
		urlStart = min;
		NSRange tweetRange = {urlStart, tweetLength-urlStart};
		NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
		NSRange urlEndRange = [tweetString rangeOfCharacterFromSet:charSet options:1 range:tweetRange];
		int urlEnd = urlEndRange.location;
		if (urlEnd > tweetLength ) {
			urlEnd = tweetLength;
		}
		urlLength = urlEnd - urlStart;
		urlAddress = [tweetString substringWithRange:NSMakeRange( urlStart, urlLength ) ];
	} else if ( mode == 2 ) {
		urlStart = min;
		NSRange tweetRange = {urlStart, tweetLength-urlStart};
		NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
		NSRange urlEndRange = [tweetString rangeOfCharacterFromSet:charSet options:1 range:tweetRange];
		int urlEnd = urlEndRange.location;
		if (urlEnd > tweetLength ) {
			urlEnd = tweetLength;
		}
		urlLength = urlEnd - urlStart;
		urlAddress = @"http://";
		NSString *urlStub = [tweetString substringWithRange:NSMakeRange( urlStart, urlLength ) ];
		urlAddress = [urlAddress stringByAppendingString:urlStub];
	} else if ( mode == 3 ) {
		int comStart = min;
		NSRange startRange = {0, comStart};
		NSRange endRange = {comStart, tweetLength - comStart};
		NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
		NSRange urlStartRange = [tweetString rangeOfCharacterFromSet:charSet options:5 range:startRange];
		NSRange urlEndRange = [tweetString rangeOfCharacterFromSet:charSet options:1 range:endRange];
		urlStart = urlStartRange.location + 1;
		if (urlStart < 0) {
			urlStart = 0;
		}
		int urlEnd = urlEndRange.location;
		if (urlEnd > tweetLength) {
			urlEnd = tweetLength;
		}
		urlLength = urlEnd - urlStart;
		urlAddress = @"http://";
		NSString *urlStub = [tweetString substringWithRange:NSMakeRange( urlStart, urlLength ) ];
		urlAddress = [urlAddress stringByAppendingString:urlStub];
	} else if ( mode == 4 ) {
		urlStart = min;
		urlStart += 1;
		NSRange tweetRange = {urlStart, tweetLength-urlStart};
		NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
		NSRange atEndRange = [tweetString rangeOfCharacterFromSet:charSet options:1 range:tweetRange];
		int atEnd = atEndRange.location;
		if (atEnd > tweetLength ) {
			atEnd = tweetLength;
		}
		urlLength = atEnd - urlStart;
		urlAddress = @"http://m.twitter.com/";
		NSString *urlStub = [tweetString substringWithRange:NSMakeRange( urlStart, urlLength ) ];
		urlAddress = [urlAddress stringByAppendingString:urlStub];
	} else {
		urlAddress = nil;
	}
	
	if (urlAddress != nil) {
		[urlArray addObject:urlAddress];
		int offset = urlStart + urlLength;
		NSNumber *offSet = [[NSNumber alloc] initWithInt:offset];
		[urlArray addObject:offSet];
		return urlArray;	
	} else {
		return urlAddress;
	}
}

- (void)dealloc {
	[urlList release];
	[urlArray release];
	[urlAddress release];
    [super dealloc];
}

@end
