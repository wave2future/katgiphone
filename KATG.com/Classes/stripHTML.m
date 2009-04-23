//
//  stripHTML.m
//  KATG.com
//
//  Created by Doug Russell on 4/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "stripHTML.h"
#import "MREntitiesConverter.h"

@implementation stripHTML

@synthesize resultString;

- (id)init {
    if([super init]) {
        resultString = [[NSString alloc] init];
    }
    return self;
}

-(id)processHtml:(NSString *)input {
	MREntitiesConverter *converter = [[MREntitiesConverter alloc] init];
	
	resultString = [resultString stringByReplacingOccurrencesOfString:(NSString *)@"<p>" withString:(NSString *)@"/n"];
	resultString = [resultString stringByReplacingOccurrencesOfString:(NSString *)@"<br>" withString:(NSString *)@"/n"];
	resultString = [converter convertEntiesInString:input];
	//NSString * returnString = nil;
	/*
	while ([resultString rangeOfString: @"<" options:1].location != NSNotFound) {
		int stringLength = resultString.length;
		int tagStart = [resultString rangeOfString: @"<" options:1].location;
		NSRange tagRange = {tagStart, stringLength-tagStart};
		NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@">"];
		NSRange tagEndRange = [resultString rangeOfCharacterFromSet:charSet options:1 range:tagRange];
		int tagEnd = tagEndRange.location;
		if (tagEnd > stringLength ) {
			tagEnd = stringLength;
		}
		//int tagLength = tagEnd - tagStart;
	returnString = [resultString substringWithRange:NSMakeRange( 0, tagStart - 1 ) ];
		returnString = [returnString substringWithRange:NSMakeRange( tagEnd + 1, stringLength ) ];
	}
	*/
	
	return resultString;
	
}

- (void)dealloc {
    [resultString release];
    [super dealloc];
}

@end