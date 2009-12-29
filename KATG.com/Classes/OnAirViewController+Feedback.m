//
//  OnAirViewController+Feedback.m
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

#import "OnAirViewController+Feedback.h"
#import "Feedback.h"

@implementation OnAirViewController (Feedback)

#pragma mark -
#pragma mark FeedBack System
#pragma mark -

#pragma mark TextField/TextView Methods
- (IBAction)resignFirstResponder:(id)sender 
{
	[self resignAllResponders];
}

- (void)textViewDidEndEditing:(UITextView *)textView 
{
	[self resignAllResponders];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([commentTextView.text isEqualToString:@"Comment"]) {
		[commentTextView setText:@""];
	}
}

- (void)resignAllResponders 
{
	[nameTextField resignFirstResponder];
	[locationTextField resignFirstResponder];
	[commentTextView resignFirstResponder];
}

- (void)setFeedbackButtonImages 
{
	// Feedback Button normal image state
	UIImage *feedbackButtonNormal = 
	[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] 
									  pathForResource:@"feedButtonNormal" 
									  ofType:@"png"]];
	feedbackButtonNormal = 
	[feedbackButtonNormal stretchableImageWithLeftCapWidth:12 
											  topCapHeight:12];
	[feedbackButton setBackgroundImage:feedbackButtonNormal 
							  forState:UIControlStateNormal];
	// Feedback Button highlighted image state
	UIImage *feedbackButtonHighlighted = 
	[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] 
									  pathForResource:@"feedButtonHighlighted" 
									  ofType:@"png"]];
	feedbackButtonHighlighted = 
	[feedbackButtonHighlighted stretchableImageWithLeftCapWidth:12 
												   topCapHeight:12];
	[feedbackButton setBackgroundImage:feedbackButtonHighlighted 
							  forState:UIControlStateHighlighted];
}

#pragma mark Feedback Post Methods
- (IBAction)submitFeedback:(id)sender 
{
	if ([shouldStream intValue] == 0) {
		return;
	}
	// Disable feedback button until this feedback is done sending
	[feedbackButton setEnabled:NO];
	// Create feedback object to send feedback
	Feedback *fb = [[Feedback alloc] init];
	[fb setDelegate:self];
	[fb setName:nameTextField.text];
	[fb setLocation:locationTextField.text];
	[fb setComment:commentTextView.text];
	[fb send];
}

- (void)feedbackDidCompleteSuccessfully:(Feedback *)fb 
{
	[fb release];
	commentTextView.text = @"";
	[feedbackButton setEnabled:YES];
}


@end
