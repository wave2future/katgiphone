//
//  ModalWebViewController.h
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

@interface ModalWebViewController : UIViewController <UIActionSheetDelegate> {
@private
	UIWebView *webView;
	UIToolbar *toolbar;
	UIBarButtonItem *doneButton;
	UIActivityIndicatorView *activityIndicator;
	BOOL disableDone;
@public
	NSURLRequest *urlRequest;
}

@property(nonatomic, retain)IBOutlet UIWebView *webView;
@property(nonatomic, retain)IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain)IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, retain)IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain)         NSURLRequest *urlRequest;
@property(nonatomic, assign)         BOOL disableDone;

- (IBAction)dismissModalViewController:(id)sender;
- (IBAction)openInSafari:(id)sender;

@end
