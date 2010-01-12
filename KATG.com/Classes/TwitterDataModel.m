//
//  TwitterDataModel.m
//  Scott Sigler
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

#import "TwitterDataModel.h"
#import "TwitterDataModel+PrivateMethods.h"
#import "TouchXML.h"

@implementation TwitterDataModel

@synthesize delegate, shouldStream;

+ (id)model
{
	return [[self alloc] init];
}

- (NSArray *)tweets
{
	return [self _getTweets];
}

- (NSArray *)otherTweets
{
	return [self _getOtherTweets];
}
- (void)cancelTweets
{
	[self _cancelTweets];
}
- (void)cancelOtherTweets
{
	[self _cancelOtherTweets];
}

- (UIImage *)image:(NSURL *)imageURL forIndexPath:(NSIndexPath *)indexPath
{
	return [self _getImage:imageURL forIndexPath:indexPath];
}

@end
