//
//  PastShowPicsDataModel+HiRes.m
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

#import "PastShowPicsDataModel+HiRes.h"
#import "ImageAdditions.h"

@implementation PastShowPicsDataModel (HiRes)

- (UIImage *)_getPic:(NSURL *)URL local:(BOOL *)fromDisk
{
	NSString *path = 
	[_dataPath stringByAppendingPathComponent:[[URL description] lastPathComponent]];
	NSData *imageData = [NSData dataWithContentsOfFile:path];
	if (imageData)
	{
		UIImage *image = [UIImage imageWithData:imageData];
		if (image) 
		{
			*fromDisk = YES;
			return image;
		}
	}
	*fromDisk = NO;
	[NSThread detachNewThreadSelector:@selector(_pollingPictureThread:) 
							 toTarget:self 
						   withObject:URL];
	return UIImageForNameExtension(@"Loading", @"png");
}
- (void)_pollingPictureThread:(NSURL *)url
{
	NSAutoreleasePool *pool = 
	[[NSAutoreleasePool alloc] init];
	NSData *imageData = 
	[NSData dataWithContentsOfURL:url];
	[self performSelectorOnMainThread:@selector(_processImageData:) 
						   withObject:[imageData retain] 
						waitUntilDone:NO];
	[self _writePicToFile:imageData name:[[url description] lastPathComponent]];
	[pool release];
}
- (void)_processImageData:(NSData *)imageData
{
	UIImage *image = [UIImage imageWithData:imageData];
	if ([(NSObject *)[self delegate] respondsToSelector:@selector(pastShowPicDataModelDidChange:)])
	{
		[[self delegate] pastShowPicDataModelDidChange:image];
	}
	[imageData release];
}
- (void)_writePicToFile:(NSData *)imageData name:(NSString *)name
{
		NSString *path = 
		[_dataPath stringByAppendingPathComponent:name];
		[imageData writeToFile:path atomically:YES];
}

@end
