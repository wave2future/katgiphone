//
//  Feedback.h
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

@protocol FeedbackDelegate;

@interface Feedback : NSObject {
	id<FeedbackDelegate> delegate;
	
	NSString *name;
	NSString *location;
	NSString *comment;
}

@property (assign, nonatomic, readwrite) id delegate;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *comment;

- (id)delegate;
- (void)setDelegate:(id)anObject;

- (void)send;
- (void)_post:(NSString *)body;
- (NSString *)_buildPostBody;
- (NSString *)_escapeString:(NSString *)string;

@end

@protocol FeedbackDelegate
@optional
- (void)feedbackDidCompleteSuccessfully:(Feedback *)fb;
- (void)feedbackFailedWithError:(Feedback *)fb error:(NSError *)error;
@end
