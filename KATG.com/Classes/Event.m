//
//  Movie.m
//  CustomTableCells
//
//  Created by Atrexis on 05/01/09.
//  Copyright 2009 Atrexis Systems Limited. All rights reserved.
//

#import "Event.h"


@implementation Event

@synthesize title, publishDate, type;

// Creates the object with primary key and title is brought into memory.
- (id)initWithTitle:(NSString *)theTitle publishDate:(NSString *)thePublishDate type:(NSString *)theType {
    if (self = [super init]) {
        title = [[NSString alloc] initWithString:theTitle];
        publishDate = [[NSString alloc] initWithString:thePublishDate];
        type = [[NSString alloc] initWithString:theType];
    }
    return self;
}

- (void)dealloc {
    [title release];
    [publishDate release];
    [type release];
    [super dealloc];
}

@end
