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
#include <sys/socket.h>
#include <netinet/in.h>

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
	return YES;
}

// Delegation methods 
- (void)applicationWillTerminate:(UIApplication *)application {
	application.applicationIconBadgeNumber = 0;
}

- (void)application:didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {	
    NSLog(@"deviceToken: %@", deviceToken);
	//NSString *token = [[NSString alloc] initWithFormat: @"%@", deviceToken];
	//[self sendProviderDeviceToken:token];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	NSLog(@"deviceToken: %@", devToken);
	NSString *token = [[NSString alloc] initWithFormat: @"%@", devToken];
	[self sendProviderDeviceToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {	
    NSLog(@"Error in registration. Error: %@", error);
}

- (void)sendProviderDeviceToken:(NSString *)token {
	NSString *myRequestString = @"http://whywontyoudie.com/tokenServer.php?dev=";
	token = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)token, NULL, NULL, kCFStringEncodingUTF8);
	myRequestString = [myRequestString stringByAppendingString:token];
	
	NSURLRequest *request = [[ NSURLRequest alloc ] initWithURL: [ NSURL URLWithString: myRequestString ] ]; 
	
	[ NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
}

- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end

