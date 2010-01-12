//
//  TwitterDataModel+PrivateMethods.m
//  Scott Sigler
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

#define kFeedAddress @"http://twitter.com/statuses/user_timeline/ScottSigler.xml"
#define kOtherFeedAddress @"http://search.twitter.com/search.atom?q=%3Ascottsigler+OR+scottsigler+OR+scott%20sigler&rpp=20"
#define kTwitterPlist @"twitter.plist"
#define kOtherTwitterPlist @"otherTwitter.plist"

//NSString *searchString = @"http://search.twitter.com/search.json?q=from%3Akeithandthegirl+OR+from%3AKeithMalley";
//searchString = [searchString stringByAppendingString: @"+OR+from%3AKaTGShowAlert+OR+%3Akeithmalley+OR+keithandthegirl+OR+katg+OR+%22keith+and+the+girl%22"];

#import "TwitterDataModel+PrivateMethods.h"
#import "TouchXML.h"
#import "Reachability.h"

@implementation TwitterDataModel (PrivateMethods)

- (id)init 
{
    if (self = [super init]) 
	{
		[[NSNotificationCenter defaultCenter] 
		 addObserver:self 
		 selector:@selector(_reachabilityChanged:) 
		 name:kReachabilityChangedNotification 
		 object:nil];		
		// Formatter to create date object from single user feed data
		// Sun Jan 10 21:32:03 +0000 2010
		_formatter = [[NSDateFormatter alloc] init];
		[_formatter setDateStyle: NSDateFormatterLongStyle];
		[_formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[_formatter setDateFormat: @"EEE MMM dd HH:mm:ss ZZZZ yyyy"];
		// Formatter to create date object from search feed data
		// <published>2010-01-10T19:59:15Z</published>
		_otherFormatter = [[NSDateFormatter alloc] init];
		[_otherFormatter setDateStyle: NSDateFormatterLongStyle];
		[_otherFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[_otherFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		[_otherFormatter setDateFormat: @"yyyy-mm-dd HH:mm:ss "];
		// Path for documents directory
		_dataPath =
		[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
											  NSUserDomainMask, 
											  YES) lastObject] retain];
		// Active image dictionary
		_images = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)_cancelTweets
{
	[_tweetThread cancel];
}
- (void)_stopTweetsThread
{
	[_tweetPool drain]; _tweetPool = nil;
	[_tweetThread cancel];
	[_tweetThread release]; _tweetThread = nil;
}
- (void)_cancelOtherTweets
{
	[_otherTweetThread cancel];
}
- (void)_stopOtherTweetsThread
{
	[_otherTweetPool drain]; _otherTweetPool = nil;
	[_otherTweetThread cancel];
	[_otherTweetThread release]; _otherTweetThread = nil;
}
- (void)dealloc
{
	delegate = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self _stopTweetsThread];
	[self _stopOtherTweetsThread];
	[_formatter release];
	[_otherFormatter release];
	[_dataPath release];
	[_images release];
	[super dealloc];
}
#pragma mark -
#pragma mark Tweets
#pragma mark -
- (NSArray *)_getTweets
{
	NSString *path = 
	[_dataPath stringByAppendingPathComponent:kTwitterPlist];
	NSArray *twt = [NSArray arrayWithContentsOfFile:path];
	if (!twt && [shouldStream intValue] > 0)
	{
		twt = [self _loadingArray];
	}
	else if (!twt && [shouldStream intValue] == 0)
	{
		twt = [self _noConnectionArray];
	}
	if ([shouldStream intValue] > 0)
	{
		_tweetThread = [[NSThread alloc] initWithTarget:self 
											   selector:@selector(_pollFeed) 
												 object:nil];
		[_tweetThread start];
	}
	else 
	{
		_pollOnConnection = YES;
	}
	return twt;
}			
- (void)_pollFeed
{
	_tweetPool = [[NSAutoreleasePool alloc] init];
	NSURL *feedURL = [NSURL URLWithString:kFeedAddress];
	NSError *error;
	if (![[NSThread currentThread] isCancelled] && [shouldStream intValue] > 0)
	{
		CXMLDocument *parser = 
		[[[CXMLDocument alloc] initWithContentsOfURL:feedURL options:0 error:&error] autorelease];
		CXMLElement *rootElement = [parser rootElement];
		NSArray *elements = [rootElement elementsForName:@"status"];
		NSMutableDictionary *tweet;
		NSMutableArray *tweets = [[NSMutableArray alloc] init];
		for (CXMLElement *element in elements)
		{
			tweet = [[NSMutableDictionary alloc] init];
			// <created_at>Sun Jan 10 21:32:03 +0000 2010</created_at>
			NSString *createdAt = [self _processElement:element forName:@"created_at"];
			if (createdAt && ![[NSThread currentThread] isCancelled])
			{
				NSDate *createdAtDate = [_formatter dateFromString:createdAt];
				if (createdAtDate && ![[NSThread currentThread] isCancelled])
				{
					[tweet setObject:createdAtDate forKey:@"CreatedAt"];
				}
			}
			//<text>Oreos acquired. Store did not have Double Stuff (the pinko commies!). Also: brat and cheese for Packers game. Oreos ... Oreos ... Oreos ...</text>
			NSString *tweetText = [self _processElement:element forName:@"text"];
			if (tweetText && ![[NSThread currentThread] isCancelled])
			{
				[tweet setObject:tweetText forKey:@"TweetText"];
			}
			NSArray *userArray = [element elementsForName:@"user"];
			if ([userArray count] == 1 && ![[NSThread currentThread] isCancelled])
			{
				CXMLElement *userElement = [userArray objectAtIndex:0];
				//<name>Scott Sigler</name>
				NSString *nameString = [self _processElement:userElement forName:@"name"];
				if (nameString && ![[NSThread currentThread] isCancelled])
				{
					[tweet setObject:nameString forKey:@"Name"];
				}
				//<screen_name>scottsigler</screen_name>
				NSString *sNameString = [self _processElement:userElement forName:@"screen_name"];
				if (sNameString && ![[NSThread currentThread] isCancelled])
				{
					[tweet setObject:sNameString forKey:@"ScreenName"];
				}
				//<profile_image_url>http://a1.twimg.com/profile_images/422871190/SiglerStank_252_normal.jpg</profile_image_url>
				NSString *urlString = [self _processElement:userElement forName:@"profile_image_url"];
				if (urlString && ![[NSThread currentThread] isCancelled])
				{
					[tweet setObject:urlString forKey:@"IconURL"];
				}
			}
			if (![[NSThread currentThread] isCancelled])
			{
				[tweets addObject:tweet];
				[tweet release];
			}
			else 
			{
				[tweet release];
				break;
			}		
		}
		if (![[NSThread currentThread] isCancelled])
		{
			_tweets = (NSArray *)[tweets copy];
			[[self delegate] tweetsDidChange:_tweets];
			[self _writeToFile:(NSArray *)[tweets copy] withPath:kTwitterPlist];
		}	
		[tweets release];
		[self _stopTweetsThread];
	}
	else
	{
		[self _stopTweetsThread];
		return;
	}
}
#pragma mark -
#pragma mark Other Tweets
#pragma mark -
- (NSArray *)_getOtherTweets
{
	NSString *path = 
	[_dataPath stringByAppendingPathComponent:kOtherTwitterPlist];
	NSArray *twt = [NSArray arrayWithContentsOfFile:path];
	if (!twt && [shouldStream intValue] > 0)
	{
		twt = [self _loadingArray];
	}
	else if (!twt && [shouldStream intValue] == 0)
	{
		twt = [self _noConnectionArray];
	}
	if ([shouldStream intValue] > 0)
	{
		_otherTweetThread = [[NSThread alloc] initWithTarget:self 
													selector:@selector(_pollOtherFeed) 
													  object:nil];
		[_otherTweetThread start];
	}
	else 
	{
		_pollOnConnection = YES;
	}
	return twt;
}
- (void)_pollOtherFeed
{
	_otherTweetPool = [[NSAutoreleasePool alloc] init];
	NSURL *feedURL = [NSURL URLWithString:kOtherFeedAddress];
	NSError *error;
	if (![[NSThread currentThread] isCancelled] && [shouldStream intValue] > 0)
	{
		CXMLDocument *parser = 
		[[[CXMLDocument alloc] initWithContentsOfURL:feedURL 
											 options:0 
											   error:&error] autorelease];
		CXMLElement *rootElement = [parser rootElement];
		NSArray *elements = [rootElement elementsForName:@"entry"];
		NSMutableDictionary *tweet;
		NSMutableArray *tweets = [[NSMutableArray alloc] init];
		for (CXMLElement *element in elements)
		{
			tweet = [[NSMutableDictionary alloc] init];
			//<published>2010-01-10T19:59:15Z</published>
			NSString *createdAt = [self _processElement:element forName:@"published"];
			createdAt = [createdAt stringByReplacingOccurrencesOfString:@"T" withString:@" "];
			createdAt = [createdAt stringByReplacingOccurrencesOfString:@"Z" withString:@" "];
			if (createdAt && ![[NSThread currentThread] isCancelled])
			{
				NSDate *createdAtDate = [_otherFormatter dateFromString:createdAt];
				if (createdAtDate && ![[NSThread currentThread] isCancelled])
				{
					[tweet setObject:createdAtDate forKey:@"CreatedAt"];
				}
			}
			//<title>Just finished reading &quot;The Rookie&quot; by Scott Sigler. It was even better than &quot;Contagious!&quot; Highly recommended to all Alabama fans-- and foes!</title>
			NSString *tweetText = [self _processElement:element forName:@"title"];
			if (tweetText && ![[NSThread currentThread] isCancelled])
			{
				[tweet setObject:tweetText forKey:@"TweetText"];
			}
			//<link type="image/png" href="http://a1.twimg.com/profile_images/616834278/rings-100_normal.jpg" rel="image"/>
			// This is a clumsy chunk of code, needs revision
			NSArray *linkArray = [element elementsForName:@"link"];
			for (CXMLElement *linkElement in linkArray) 
			{
				NSArray *linkAttributes = [linkElement attributes];
				for (CXMLNode *node in linkAttributes) 
				{
					if ([[node stringValue] rangeOfString:@"image/"].location != NSNotFound)
					{
						NSString *urlString = [[linkAttributes objectAtIndex:1] stringValue];
						if (urlString) [tweet setObject:urlString forKey:@"IconURL"];
					}
				}
			}
			NSArray *userArray = [element elementsForName:@"author"];
			if ([userArray count] == 1)
			{
				CXMLElement *userElement = [userArray objectAtIndex:0];
				//<name>docartemis (Ginger Campbell, MD)</name>
				NSString *nameString = [self _processElement:userElement forName:@"name"];
				if (nameString && ![[NSThread currentThread] isCancelled])
				{
					[tweet setObject:nameString forKey:@"Name"];
					[tweet setObject:nameString forKey:@"ScreenName"];
				}
			}
			if (![[NSThread currentThread] isCancelled])
			{
				[tweets addObject:tweet];
				[tweet release];
			}
			else 
			{
				[tweet release];
				break;
			}
		}
		if (![[NSThread currentThread] isCancelled])
		{
			_tweets = (NSArray *)[tweets copy];
			[[self delegate] tweetsDidChange:_tweets];
			[self _writeToFile:(NSArray *)[tweets copy] withPath:kOtherTwitterPlist];
		}	
		[tweets release];
		[self _stopOtherTweetsThread];
	}
	else
	{
		[self _stopOtherTweetsThread];
		return;
	}
}
#pragma mark -
#pragma mark label
#pragma mark -
- (NSArray *)_loadingArray
{
	NSDictionary *twt = 
	[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
										 [NSDate date],
										 @"Loading Tweets",
										 @"",
										 @"",
										 @"", nil] 
								forKeys:[NSArray arrayWithObjects:
										 @"CreatedAt",
										 @"TweetText",
										 @"Name",
										 @"ScreenName",
										 @"IconURL", nil]];
	return [NSArray arrayWithObject:twt];
}
- (NSArray *)_noConnectionArray
{
	NSDictionary *twt = 
	[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
										 [NSDate date],
										 @"Tweets Unavailable",
										 @"",
										 @"",
										 @"", nil] 
								forKeys:[NSArray arrayWithObjects:
										 @"CreatedAt",
										 @"TweetText",
										 @"Name",
										 @"ScreenName",
										 @"IconURL", nil]];
	return [NSArray arrayWithObject:twt];
}
- (id)_processElement:(CXMLElement *)element forName:(NSString *)name
{
	if (![[NSThread currentThread] isCancelled])
	{
		NSArray *array = [element elementsForName:name];
		if ([array count] == 1 && ![[NSThread currentThread] isCancelled])
		{
			NSString *string = [[array objectAtIndex:0] stringValue];
			if (string && ![[NSThread currentThread] isCancelled])
			{
				return string;
			}
		}	
	}
	return nil;
}
- (void)_writeToFile:(NSArray *)tweets withPath:(NSString *)name
{
	if (tweets && [tweets count] > 0)
	{
		NSString *path = [_dataPath stringByAppendingPathComponent:name];
		[tweets writeToFile:path atomically:YES];
	}
}
#pragma mark -
#pragma mark Tweet Icons
#pragma mark -
- (UIImage *)_getImage:(NSURL *)imageURL forIndexPath:(NSIndexPath *)indexPath
{
	NSString *fileName = [[imageURL description] lastPathComponent];
	NSData *imageData = [_images objectForKey:fileName];
	UIImage *image;
	if (imageData)
	{
		//NSLog(@"%@ from image dictionary", fileName);
		image = [UIImage imageWithData:imageData];
	}
	else 
	{
		[NSThread detachNewThreadSelector:@selector(stupidIntermediateMethod:) 
								 toTarget:self 
							   withObject:[NSArray arrayWithObjects:imageURL, 
										   indexPath, nil]];
		//NSLog(@"Temporary Image", fileName);
		image = [UIImage imageNamed:@"Icon.png"];
	}
	return image;
}
- (void)stupidIntermediateMethod:(NSArray *)array
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSURL *imageURL = [array objectAtIndex:0];
	NSIndexPath *indexPath = [array objectAtIndex:1];
	NSString *fileName = [[imageURL description] lastPathComponent];
	NSString *path = [_dataPath stringByAppendingPathComponent:fileName];
	NSData *imageData = [NSData dataWithContentsOfFile:path];
	if (imageData)
	{
		//NSLog(@"%@ from disk", fileName);
		[self performSelectorOnMainThread:@selector(addToImagesDictionary:) 
							   withObject:[NSArray arrayWithObjects:
										   fileName, 
										   imageData, nil] 
							waitUntilDone:YES];
		UIImage *image = [UIImage imageWithData:imageData];
		if (image) [self performSelectorOnMainThread:@selector(anotherStupidIntermediateMethod:) 
										  withObject:[NSArray arrayWithObjects:image, indexPath, nil] 
									   waitUntilDone:NO];
	}
	else 
	{
		[self downloadImage:imageURL forIndexPath:indexPath];
	}
	[pool release];
}
- (void)downloadImage:(NSURL *)imageURL forIndexPath:(NSIndexPath *)indexPath
{
	NSString *fileName = [[imageURL description] lastPathComponent];
	NSString *path = [_dataPath stringByAppendingPathComponent:fileName];
	NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
	if (imageData) 
	{
		//NSLog(@"%@ from web", fileName);
		[imageData writeToFile:path atomically:YES];
		[self performSelectorOnMainThread:@selector(addToImagesDictionary:) 
							   withObject:[NSArray arrayWithObjects:
										   fileName, 
										   imageData, nil] 
							waitUntilDone:YES];
		UIImage *image = [UIImage imageWithData:imageData];
		if (image) [self performSelectorOnMainThread:@selector(anotherStupidIntermediateMethod:) 
										  withObject:[NSArray arrayWithObjects:image, indexPath, nil] 
									   waitUntilDone:NO];
	}
}
- (void)anotherStupidIntermediateMethod:(NSArray *)array
{
	UIImage *image = [array objectAtIndex:0];
	NSIndexPath *indexPath = [array objectAtIndex:1];
	[[self delegate] imageDidChange:image forIndexPath:indexPath];
}
- (void)addToImagesDictionary:(NSArray *)array
{
	if ([NSThread isMainThread])
	{
		NSString *fileName = [array objectAtIndex:0];
		NSData *imageData = [array objectAtIndex:1];
		[_images setObject:imageData forKey:fileName];
	}
}
#pragma mark -
#pragma mark Reachability
#pragma mark -
- (void)_reachabilityChanged:(NSNotification* )note
{
	Reachability *curReach = [note object];
	//NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self _updateReachability:curReach];
}
- (void)_updateReachability:(Reachability*)curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	switch (netStatus) {
		case NotReachable:
		{
			shouldStream = [NSNumber numberWithInt:0];
			break;
		}
		case ReachableViaWWAN:
		{
			shouldStream = [NSNumber numberWithInt:2];
			break;
		}
		case ReachableViaWiFi:
		{
			shouldStream = [NSNumber numberWithInt:3];
			break;
		}
	}
}

@end
