//
//  GrabXMLFeed.h
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

@protocol GrabXMLFeedDelegate;

@interface GrabXMLFeed : NSObject {
@private
	id<GrabXMLFeedDelegate> delegate;
	NSURL    *_url;
	NSString *_xpath;
@public
	NSMutableArray *feedEntries;
	NSInteger	   instanceNumber;
	BOOL           cancelled;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSMutableArray *feedEntries;

- (id)initWithFeed:(NSString *)feedAddress xPath:(NSString *)xPath;
- (void)parse;
- (NSInteger)instanceNumber;
- (void)setInstanceNumber:(NSInteger)instance;
- (void)cancel;
- (BOOL)isCancelled;

@end

@protocol GrabXMLFeedDelegate
@optional
- (void)parsingDidCompleteForNode:(NSDictionary *)node parser:(GrabXMLFeed *)parser;
- (void)parsingDidCompleteSuccessfully:(GrabXMLFeed *)parser;
@end
