//
//  EventDetailViewController.h
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

@interface EventDetailViewController : UIViewController {
	UIWebView	 *webView;
	NSDictionary *event;
	
	UILabel		 *titleLabel;
	UILabel		 *dayLabel;
	UILabel		 *dateLabel;
	UILabel		 *timeLabel;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UILabel	 *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel	 *dayLabel;
@property (nonatomic, retain) IBOutlet UILabel	 *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel	 *timeLabel;
@property (nonatomic, retain) NSDictionary		 *event;

@end
