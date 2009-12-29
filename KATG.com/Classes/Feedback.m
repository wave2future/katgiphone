//
//  Feedback.m
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

#import "Feedback.h"

@implementation Feedback

@synthesize name;
@synthesize location;
@synthesize comment;

- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)anObject
{
	delegate = anObject;
}

- (void)send {
	NSString *postBody = [self _buildPostBody];
	[self performSelectorOnMainThread:@selector(_post:) withObject:postBody waitUntilDone:NO];
	[[self delegate] feedbackDidCompleteSuccessfully:self];
}

- (void)_post:(NSString *)body {
	NSData *requestData = [NSData dataWithBytes:[body UTF8String] length:[body length]];
	NSMutableURLRequest *request = 
	[[NSMutableURLRequest alloc] initWithURL:
	 [NSURL URLWithString:@"http://www.attackwork.com/Voxback/Comment-Form-Iframe.aspx"]]; 
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:requestData];
	[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	[request release];
}

- (NSString *)_buildPostBody {
	NSMutableString *postBody = [NSMutableString string];
	[postBody appendString:@"Name="];
	[postBody appendString:[self _escapeString:name]];
	[postBody appendString:@"&Location="];
	[postBody appendString:[self _escapeString:location]];
	[postBody appendString:@"&Comment="];
	[postBody appendString:[self _escapeString:comment]];
	[postBody appendString:@"&ButtonSubmit=Send+Comment"];
	[postBody appendString:@"&HiddenVoxbackId=3&HiddenMixerCode=IEOSE"];
	return (NSString *)postBody;
}

- (NSString *)_escapeString:(NSString *)string {
	CFStringRef escaped =  CFURLCreateStringByAddingPercentEscapes (kCFAllocatorDefault,
																	(CFStringRef)string,
																	CFSTR(""),
																	CFSTR("&=?"),
																	kCFStringEncodingUTF8);
	NSString *escapedString = [NSString stringWithString:(NSString *)escaped];
	CFRelease(escaped);
	return escapedString;
}

- (void)dealloc {
	delegate = nil;
	[name release];
	[location release];
	[comment release];
	[super dealloc];
}

@end
