//
//  KATG_comAppDelegate.m
//  KATG.com
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "KATG_comAppDelegate.h"


@implementation KATG_comAppDelegate

@synthesize window;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
	[application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | 
													 UIRemoteNotificationTypeSound | 
													 UIRemoteNotificationTypeBadge)];
}

// Delegation methods 
- (void)applicationWillTerminate:(UIApplication *)application {
	application.applicationIconBadgeNumber = 0;
}

- (void)application:didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {	
    NSLog(@"deviceToken: %@", deviceToken);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	NSLog(@"deviceToken: %@", devToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {	
    NSLog(@"Error in registration. Error: %@", error);
}

- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end

