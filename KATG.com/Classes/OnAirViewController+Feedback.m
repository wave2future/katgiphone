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
#import "ImageAdditions.h"

@implementation OnAirViewController (Feedback)

#pragma mark -
#pragma mark FeedBack System
#pragma mark -
#pragma mark TextField/TextView Methods
// action linked to transparent button behind textview
- (IBAction)resignFirstResponder:(id)sender 
{
	[self resignAllResponders];
}
// Delegate method called when user exits textview
- (void)textViewDidEndEditing:(UITextView *)textView 
{
	[self resignAllResponders];
}
// Delegate method called when user enters text view
// If text view contains stock value of "Comment"
// it is automatically cleared
- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([commentTextView.text isEqualToString:@"Comment"]) {
		[commentTextView setText:@""];
	}
}
// Resign responder for all text fields,
// dissmissing the keyboard
- (void)resignAllResponders 
{
	[nameTextField resignFirstResponder];
	[locationTextField resignFirstResponder];
	[commentTextView resignFirstResponder];
}
// Set custom button images for feedback button
- (void)setFeedbackButtonImages 
{
	// Feedback Button normal image state
	UIImage *feedbackButtonNormal = 
	 UIImageForNameExtension(@"feedButtonNormal", @"png");
	feedbackButtonNormal = 
	[feedbackButtonNormal stretchableImageWithLeftCapWidth:12 
											  topCapHeight:12];
	[feedbackButton setBackgroundImage:feedbackButtonNormal 
							  forState:UIControlStateNormal];
	// Feedback Button highlighted image state
	UIImage *feedbackButtonHighlighted = 
	UIImageForNameExtension(@"feedButtonHighlighted", @"png");
	feedbackButtonHighlighted = 
	[feedbackButtonHighlighted stretchableImageWithLeftCapWidth:12 
												   topCapHeight:12];
	[feedbackButton setBackgroundImage:feedbackButtonHighlighted 
							  forState:UIControlStateHighlighted];
}
#pragma mark Feedback Post Methods
// Create feedback object from text field contents
// Temporarily disable feedback button
- (IBAction)submitFeedback:(id)sender 
{
	if ([shouldStream intValue] == 0) // If not connected return
	{
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
// Delegate method when feedback is done sending
// Clears comment text view, reenables feedbackbutton
- (void)feedbackDidCompleteSuccessfully:(Feedback *)fb 
{
	[fb release];
	commentTextView.text = @"";
	[feedbackButton setEnabled:YES];
}

@end
