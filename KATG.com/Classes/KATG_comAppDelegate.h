//
//  KATG_comAppDelegate.h
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

@class Reachability;
@interface KATG_comAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	// Window and Tab Bar Controller
    UIWindow *window;
    UITabBarController *tabBarController;
	// Reachability to make sure katg.com is available
	Reachability *hostReach;
	// Read user preferences, etc
	NSUserDefaults *userDefaults;
	// ShouldStream indicates connection status:
	// 0 No Connection
	// 1 WWAN Connection, stream past shows over WWAN preference is set to NO
	// 2 WWAN Connection, stream past shows over WWAN preference is set to YES
	// 3 Wifi Connection
	NSNumber *shouldStream;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, assign) NSUserDefaults *userDefaults;
@property (nonatomic, retain) NSNumber *shouldStream;

// Send in Token for Push Notifications
- (void)sendProviderDeviceToken:(id)deviceTokenBytes;
// Set up reachability object
- (void)checkReachability;
// Respond to changes in reachability status
- (void)updateReachability:(Reachability*)curReach;
- (void)reachabilityChanged:(NSNotification* )note;

@end
