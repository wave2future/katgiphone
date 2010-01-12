//
//  TwitterDataModel+PrivateMethods.h
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

@class CXMLElement;
@interface TwitterDataModel (PrivateMethods)

- (NSArray *)_getTweets;
- (void)_cancelTweets;
- (void)_stopTweetsThread;
- (void)_pollFeed;
- (id)_processElement:(CXMLElement *)element forName:(NSString *)name;
- (NSArray *)_getOtherTweets;
- (void)_cancelOtherTweets;
- (void)_stopOtherTweetsThread;
- (void)_pollOtherFeed;
- (UIImage *)_getImage:(NSURL *)imageURL forIndexPath:(NSIndexPath *)indexPath;
- (void)downloadImage:(NSURL *)imageURL forIndexPath:(NSIndexPath *)indexPath;
- (void)addToImagesDictionary:(NSArray *)array;

@end
