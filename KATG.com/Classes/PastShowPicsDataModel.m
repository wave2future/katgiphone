//
//  PastShowPicsDataModel.m
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

#import "PastShowPicsDataModel.h"
#import "PastShowPicsDataModel+PrivateMethods.h"
#import "PastShowPicsDataModel+Thumbs.h"
#import "PastShowPicsDataModel+HiRes.h"
#import "FlurryAPI.h"

@implementation PastShowPicsDataModel

@synthesize delegate;
@synthesize shouldStream;

+ (id)model // Returned instance has a retain count of 1
{
	return [[self alloc] init];
}
- (NSArray *)pics:(NSString *)ID // Returned array will have a retain count of 1
{
	[FlurryAPI logEvent:@"pics" withParameters:[NSDictionary dictionaryWithObject:ID forKey:@"ID"]];
	return [self _getPics:ID];
}
- (UIImage *)pic:(NSURL *)URL local:(BOOL *)fromDisk // Returned image will have a retain count of 0
{
	[FlurryAPI logEvent:@"picfromurl" 
		 withParameters:[NSDictionary dictionaryWithObject:[URL description] 
													forKey:@"URL"]];
	BOOL local = NO;
	UIImage *image =  [self _getPic:URL local:&local];
	*fromDisk = local;
	return image;
}
- (void)cancel
{
	[self _cancel];
}

@end
