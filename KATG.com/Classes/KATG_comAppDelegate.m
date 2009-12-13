//
//  KATG_comAppDelegate.m
//  KATG.com
//  
//  Copyright 2008 Doug Russell
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

#import "KATG_comAppDelegate.h"
#import "Beacon.h"
#include <sys/socket.h>
#include <netinet/in.h>


@implementation KATG_comAppDelegate

@synthesize window;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
	[application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | 
													 UIRemoteNotificationTypeBadge | 
													 UIRemoteNotificationTypeSound)];
	if ([launchOptions count] > 0) {
		NSString *alertMessage = [[[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] 
								   objectForKey:@"aps"] 
								   objectForKey:@"alert"];
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Notification"
							  message:alertMessage 
							  delegate:nil
							  cancelButtonTitle:@"Continue" 
							  otherButtonTitles:nil];
		[alert show];
		[alert autorelease];
	}
	NSString *applicationCode = @"a38a2cbef55901a33781c4b41d9c1a2b";
	[Beacon initAndStartBeaconWithApplicationCode:applicationCode useCoreLocation:NO useOnlyWiFi:NO];
	return YES;
}

#pragma mark Termination Notification
// Post notification triggered by app termination, used by On Air View and Tweet View to save data
- (void)talkToOnAirView { 
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"ApplicationWillTerminate" 
	 object:@"Terminate"]; 
}

// Delegation methods 
- (void)applicationWillTerminate:(UIApplication *)application {
	 application.applicationIconBadgeNumber = 0;
	[self talkToOnAirView];
	[Beacon endBeacon];
}

#pragma mark Push Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	//NSLog(@"deviceToken: %@", deviceToken);
	NSString *token = [[NSString alloc] initWithFormat: @"%@", deviceToken];
	[self sendProviderDeviceToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {	
    //NSLog(@"Error in registration. Error: %@", error);
}

- (void)sendProviderDeviceToken:(NSString *)token {		
	NSString *myRequestString = @"http://app.keithandthegirl.com/app/tokenserver/tokenserver.php?dev=";
	token = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)token, NULL, NULL, kCFStringEncodingUTF8);
	myRequestString = [myRequestString stringByAppendingString:token];
	NSURLRequest *request = [[ NSURLRequest alloc ] initWithURL: [ NSURL URLWithString: myRequestString ] ]; 
	[ NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
	[request autorelease];
	[token release];
}

#pragma mark System Stuff
- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end

