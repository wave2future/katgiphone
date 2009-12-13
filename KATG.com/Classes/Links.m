//
//  Links.m
//  KATG.com
//
//  Copyright 2008 Doug Russell
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

#import "Links.h"

BOOL inApp;

@implementation Links

@synthesize title, url;

// Creates the object with primary key and title is brought into memory.
- (id)initWithTitle:(NSString *)theTitle withURL:(NSString *)theURL withInApp:(BOOL)theInApp {	
	if (self = [super init]) {
		title = [NSString stringWithString:theTitle];
		url = [NSString stringWithString:theURL];
		inApp = theInApp;
	}		
    return self;
}

-(BOOL)inApp {
	return inApp;
}

-(void)setInApp:(BOOL)inAppValue {
	inApp = inAppValue;
}

- (void)dealloc {
    [title release];
    [url release];
    [super dealloc];
}

@end
