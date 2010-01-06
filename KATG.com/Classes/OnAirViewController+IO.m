//
//  OnAirViewController+IO.m
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

#import "OnAirViewController+IO.h"
#import "OnAirViewController+AudioStreamer.h"

@implementation OnAirViewController (IO)

- (void)loadDefaults 
{
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self
	 selector:@selector(writeDefaults) 
	 name:@"UIApplicationWillTerminateNotification" 
	 object:nil];
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *name = [userDefaults objectForKey:@"Name"];
	if (name != nil) 
	{
		[nameTextField setText:name];
	}
	NSString *location = [userDefaults objectForKey:@"Location"];
	if (location != nil) 
	{
		[locationTextField setText:location];
	}
	NSString *comment = [userDefaults objectForKey:@"Comment"];
	if (comment != nil) 
	{
		[commentTextView setText:comment];
	}
	if ([userDefaults boolForKey:@"playing"] && [shouldStream intValue] > 0) 
	{
		[self audioButtonPressed:nil];
	} 
	else if ([userDefaults boolForKey:@"playing"] && [shouldStream intValue] == 0) 
	{
		playOnConnection = YES;
	}
}
- (void)writeDefaults  
{
	if ([nameTextField.text length] > 0) 
	{
		[userDefaults setObject:nameTextField.text forKey:@"Name"];
	}
	if ([locationTextField.text length] > 0) 
	{
		[userDefaults setObject:locationTextField.text forKey:@"Location"];
	}
	if ([commentTextView.text length] > 0) 
	{
		[userDefaults setObject:commentTextView.text forKey:@"Comment"];
	}
	if (streamer) 
	{
		[userDefaults setBool:YES forKey:@"playing"];
	} 
	else 
	{
		[userDefaults setBool:NO forKey:@"playing"];
	}
	[userDefaults synchronize];
}

@end
