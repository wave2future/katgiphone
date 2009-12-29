//
//  KATG_comAppDelegate.m
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

#import "KATG_comAppDelegate.h"
#import "Reachability.h"

@implementation KATG_comAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize userDefaults;
@synthesize shouldStream;

#pragma mark -
#pragma mark Application Delegate Methods
#pragma mark -
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	// Set tab bar delegate to take advantage of didSelectViewController
	[tabBarController setDelegate:self];
	// Finds OnAirViewController in stack of viewControllers in tab controller and sets it's delegate
	for (id vC in [tabBarController viewControllers]) 
	{
		if ([[[vC class] description] isEqualToString:@"OnAirViewController"]) 
		{
			[vC setDelegate:self];
			break;
		}
	}
	[window addSubview:tabBarController.view];
	// Register for push notifications
	[application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | 
													 UIRemoteNotificationTypeBadge | 
													 UIRemoteNotificationTypeSound)];
	// If app is launched from a notification, display that notification in an alertview
	if ([launchOptions count] > 0) 
	{
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
		[alert release];
	}
	// Register reachability object
	[self checkReachability];
	return YES;
}
// When application closes clear any badge icons
- (void)applicationWillTerminate:(UIApplication *)application 
{
	application.applicationIconBadgeNumber = 0;
}
#pragma mark Push Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{
	NSString *token = [[NSString alloc] initWithFormat: @"%@", deviceToken];
	[self sendProviderDeviceToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error 
{	
    //NSLog(@"Error in registration. Error: %@", error);
}
// This needs some attention, seems awkward
- (void)sendProviderDeviceToken:(NSString *)token 
{		
	NSString *myRequestString = @"http://app.keithandthegirl.com/app/tokenserver/tokenserver.php?dev=";
	token = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)token, NULL, NULL, kCFStringEncodingUTF8);
	myRequestString = [myRequestString stringByAppendingString:token];
	NSURLRequest *request = [[ NSURLRequest alloc ] initWithURL: [ NSURL URLWithString: myRequestString ] ]; 
	[NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
	[request autorelease];
	[token release];
}
#pragma mark -
#pragma mark Tab Bar Delegate Methods
#pragma mark -
// Notifies change in tab bar selected view controller
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController 
{
	// Checks if selected controller is a UINavigation controller and if it is checks the class
	// of it's top view controller, if the top view controller is the PastShowsTableViewController
	// or (future change) twitter then set it's delegate
	if ([[[viewController class] description] isEqualToString:@"UINavigationController"]) 
	{
		if ([[[[viewController topViewController] class] description] isEqualToString:@"PastShowsTableViewController"]) {
			[[viewController topViewController] setDelegate:self];
		}
	}
}
#pragma mark -
#pragma mark Reachability
#pragma mark -
// Access user defaults, register for changes in reachability an start reachability object
- (void)checkReachability 
{
	userDefaults = [NSUserDefaults standardUserDefaults];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(reachabilityChanged:) 
												 name:kReachabilityChangedNotification 
											   object:nil];
	hostReach = [[Reachability reachabilityWithHostName: @"www.keithandthegirl.com"] retain];
	[hostReach startNotifer];
}
// Respond to changes in reachability
- (void)reachabilityChanged:(NSNotification* )note
{
	Reachability *curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateReachability:curReach];
}
// ShouldStream indicates connection status:
// 0 No Connection
// 1 WWAN Connection, stream past shows over WWAN preference is set to NO
// 2 WWAN Connection, stream past shows over WWAN preference is set to YES
// 3 Wifi Connection
// If no connection is available inform user with alert
- (void)updateReachability:(Reachability*)curReach
{
	BOOL streamPref = [userDefaults boolForKey:@"StreamPSOverCell"];
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	switch (netStatus) {
		case NotReachable:
		{
			shouldStream = [NSNumber numberWithInt:0];
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"NO INTERNET CONNECTION"
								  message:@"This Application requires an active internet connection. Please connect to wifi or cellular data network for full application functionality." 
								  delegate:nil
								  cancelButtonTitle:@"Continue" 
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
		case ReachableViaWWAN:
		{
			if (streamPref) 
			{
				shouldStream = [NSNumber numberWithInt:2];
			} 
			else 
			{
				shouldStream = [NSNumber numberWithInt:1];
			}
			break;
		}
		case ReachableViaWiFi:
		{
			shouldStream = [NSNumber numberWithInt:3];
			break;
		}
	}
}

#pragma mark -
#pragma mark Cleanup
#pragma mark -
- (void)dealloc 
{
    [tabBarController release];
    [window release];
	[hostReach release];
    [super dealloc];
}

@end

