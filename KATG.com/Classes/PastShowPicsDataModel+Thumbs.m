//
//  PastShowPicsDataModel+Thumbs.m
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

#import "PastShowPicsDataModel+Thumbs.h"

@implementation PastShowPicsDataModel (Thumbs)

- (void)_downloadThumbs
{
	_imageThread = 
	[[NSThread alloc] initWithTarget:self 
							selector:@selector(_downloadThumbsThread) 
							  object:nil];
	[_imageThread start];
}
- (void)_downloadThumbsThread
{
	_imagePool = 
	[[NSAutoreleasePool alloc] init];
	if (_picsProxyImages.count != 0) 
	{
		[_picsProxyImages removeAllObjects];
	}
	[_picsProxyImages addObjectsFromArray:_pics];
	for (int n = 0; n < [_picsProxyImages count]; n++)
	{
		if ([_imageThread isCancelled]) {
			break;
		}
		NSDictionary *pic = 
		[_picsProxyImages objectAtIndex:n];
		NSError *error;
		NSData *data = 
		[NSData dataWithContentsOfURL:
		 [NSURL URLWithString:[pic objectForKey:@"URL"]] 
							  options:NSUncachedRead 
								error:&error];
		if (data && ![_imageThread isCancelled])
		{
			
			
			
			NSDictionary *dictionary = 
			[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
												 [[pic objectForKey:@"URL"] stringByReplacingOccurrencesOfString:@"-Thumb" withString:@""],
												 [pic objectForKey:@"Title"],
												 [pic objectForKey:@"Description"], 
												 data, nil]
										forKeys:[NSArray arrayWithObjects:
												 @"URL",
												 @"Title",
												 @"Description", 
												 @"Data", nil]];
			[_picsProxyImages replaceObjectAtIndex:n withObject:dictionary];
			[_pics release];
			_pics = (NSArray *)[_picsProxyImages copy];
			if (delegate && ![_imageThread isCancelled])
			{
				[[self delegate] pastShowPicsDataModelDidChange:_pics];
			}
		} 
		else 
		{
			// Handle error;
			//NSLog([error description]);
		}
	}
	[self performSelectorOnMainThread:@selector(_writePicsToFile:) 
						   withObject:_ID
						waitUntilDone:NO];
	[_picsProxyImages removeAllObjects];
	[_imagePool drain]; _imagePool = nil;
	if (![_imageThread isCancelled]) 
	{
		[self _stopImageThread];
	}
}
- (void)_stopImageThread 
{
	[_imageThread cancel];
	[_imageThread release]; _imageThread = nil;
}

@end
