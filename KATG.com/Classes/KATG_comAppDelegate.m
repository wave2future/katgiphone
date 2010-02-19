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
#import "NSData+Base64Additions.h"
#import "FlurryAPI.h"

void uncaughtExceptionHandler(NSException *exception) 
{
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

@implementation KATG_comAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize shouldStream;

#pragma mark -
#pragma mark Application Delegate Methods
#pragma mark -
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	// Sending uncaught exceptions to flurry
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	// Start flurry tracker
	[FlurryAPI startSession:@"336AP3RPEPG53RGVUQMV"];
	// add view
	[window addSubview:tabBarController.view];
	// Register for push notifications
	[application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | 
													 UIRemoteNotificationTypeBadge | 
													 UIRemoteNotificationTypeSound)];
	// If app is launched from a notification, display that notification in an alertview
	if ([launchOptions count] > 0) 
	{
		NSString *alertMessage = 
		[[[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] 
		  objectForKey:@"aps"] 
		 objectForKey:@"alert"];
		if (alertMessage)
		{
			UIAlertView *alert = [[UIAlertView alloc] 
								  initWithTitle:@"Notification"
								  message:alertMessage 
								  delegate:nil
								  cancelButtonTitle:@"Continue" 
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	// Register reachability object
	[self checkReachability];
	return YES;
}
- (void)applicationWillTerminate:(UIApplication *)application 
{ // When application closes clear any badge icons
	application.applicationIconBadgeNumber = 0;
}
#pragma mark Push Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{ // pass device token to send method
//	NSString *token = [[deviceToken encodeWebSafeBase64ForData] retain];
//	NSLog(token);
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"token" message:token delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
//	[alertView show];
//	[alertView release];
	NSString *token = [[NSString alloc] initWithFormat: @"%@", deviceToken];
	[self sendProviderDeviceToken:token];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error 
{ // Log a failure to register for push
	[FlurryAPI logError:@"failToRegisterPush" message:@"failToRegisterPush" exception:error];
}
- (void)sendProviderDeviceToken:(NSString *)token 
{ // This needs some attention, seems awkward, should be threaded
	NSString *myRequestString = 
	@"http://app.keithandthegirl.com/app/tokenserver/tokenserver.php?dev=";
	token = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)token, NULL, NULL, kCFStringEncodingUTF8);
	myRequestString = [myRequestString stringByAppendingString:token];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:myRequestString]]; 
	[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	[request autorelease];
	[token release];
}
#pragma mark -
#pragma mark Reachability
#pragma mark -
// Access user defaults, register for changes in reachability an start reachability object
- (void)checkReachability 
{
	userDefaults = [NSUserDefaults standardUserDefaults];
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(reachabilityChanged:) 
	 name:kReachabilityChangedNotification 
	 object:nil];
	hostReach = 
	[[Reachability reachabilityWithHostName:@"www.keithandthegirl.com"] retain];
	[hostReach startNotifer];
}
// Respond to changes in reachability
- (void)reachabilityChanged:(NSNotification* )notification
{
	Reachability *curReach = [notification object];
	//NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [tabBarController release];
    [window release];
	[hostReach release];
    [super dealloc];
}

@end

