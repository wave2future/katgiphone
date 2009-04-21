//
//  sanitizeField.m
//  KATG.com
//
//  Created by Doug Russell on 4/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "sanitizeField.h"


@implementation sanitizeField

- (id)init {
	return self;
}
	
- (id)stringCleaner:(NSString *)dirtString {
	cleanString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)dirtString, NULL, NULL, kCFStringEncodingUTF8);
	cleanString = [cleanString stringByReplacingOccurrencesOfString:(NSString *)@"&" withString:(NSString *)@"and"];
	return cleanString;
}

@end