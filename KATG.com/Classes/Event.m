//
//  Event.m
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

#import "Event.h"
#import "MREntitiesConverter.h"


@implementation Event

@synthesize title, publishTime, publishDate, type, detail;

// Creates the object with primary key and title is brought into memory.
- (id)initWithTitle:(NSString *)theTitle publishTime:(NSString *)thePublishTime publishDate:(NSString *)thePublishDate type:(NSString *)theType detail:(NSString *)theDetail {
    MREntitiesConverter *converter = [[MREntitiesConverter alloc] init];
	
	if (self = [super init]) {
        title = [[NSString alloc] initWithString:theTitle];
        publishTime = [[NSString alloc] initWithString:thePublishTime];
		publishDate = [[NSString alloc] initWithString:thePublishDate];
        type = [[NSString alloc] initWithString:theType];
		
		//***********************************************************************************************************************************************
		//* detail converter
		//*
		//* Creates a string from the raw events detail from the feed
		//* Replaces <p> with <p>\n so that text formats on the page correctly
		//* Replaces "Here's how to listen: http://www.keithandthegirl.com/Live/HowToListen.aspx" with "Check out the On Air tab to listen"
		//* Passes conditioned string to converter convertEntitiesInString (an implementation using NSXMLParser) to strip out anything wrapped in <>
		//***********************************************************************************************************************************************
		/*detail = [converter convertEntitiesInString:
				  [[[NSString stringWithString:theDetail] stringByReplacingOccurrencesOfString:(NSString *)@"<p>" 
				   withString:(NSString *)@"<p>\n"]
				   stringByReplacingOccurrencesOfString:(NSString *)@"<p>\nHere's how to listen: <a href=\"../Live/HowToListen.aspx\" target=\"_blank\"><font face=\"Arial\" size=\"2\">http://www.keithandthegirl.com/Live/HowToListen.aspx</font></a></p>"
				   withString:(NSString *)@"<p>\nCheck out the On Air tab to listen</p>"]];*/
		detail = [[[[NSString alloc] initWithString:theDetail] stringByReplacingOccurrencesOfString:(NSString *)@"<p>" withString:(NSString *)@"<p>\n"] stringByReplacingOccurrencesOfString:(NSString *)@"<p>\nHere's how to listen: <a href=\"../Live/HowToListen.aspx\" target=\"_blank\"><font face=\"Arial\" size=\"2\">http://www.keithandthegirl.com/Live/HowToListen.aspx</font></a></p>" withString:(NSString *)@"<p>\nCheck out the On Air tab to listen</p>"];
		detail = [converter convertEntitiesInString:detail];
	}
	
	[converter release];
	
    return self;
}

- (void)dealloc {
    [title release];
    [publishTime release];
	[publishDate release];
    [type release];
	[detail release];
    [super dealloc];
}

@end

