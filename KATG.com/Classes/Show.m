//
//  Show.m
//  NSXML
//
//  Created by Doug Russell on 5/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Show.h"


@implementation Show

@synthesize title, publishDate, link, detail;

// Creates the object with primary key and title is brought into memory.
- (id)initWithTitle:(NSString *)theTitle publishDate:(NSString *)thePublishDate link:(NSString *)theLink detail:(NSString *)theDetail {	
	if (self = [super init]) {
        title = [[NSString alloc] initWithString:theTitle];
		publishDate = [[NSString alloc] initWithString:thePublishDate];
        link = [[NSString alloc] initWithString:theLink];
		detail = [[NSString alloc] initWithString:theDetail];
    }
	
    return self;
}

- (void)dealloc {
    [title release];
	[publishDate release];
    [link release];
	[detail release];
    [super dealloc];
}

@end
