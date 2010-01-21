//
//  TwitterSingleDataModel+PrivateMethods.m
//  KATG.com
//
//  Created by Doug Russell on 1/20/10.
//  Copyright 2010 Paper Software. All rights reserved.
//

#define kFeedAddress @"http://twitter.com/statuses/user_timeline/%@.xml"
#define kTwitterPlist @"twitter_%@.plist"

#import "TwitterSingleDataModel+PrivateMethods.h"
#import "TouchXML.h"
#import "Reachability.h"

@implementation TwitterSingleDataModel (PrivateMethods)

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
- (void)dealloc
{
	delegate = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self _stopTweetsThread];
	[_formatter release];
	[_dataPath release];
	[_images release];
	[super dealloc];
}
#pragma mark -
#pragma mark Tweets
#pragma mark -
- (NSArray *)_getTweetsForUser:(NSString *)user
{
	NSString *plist = [NSString stringWithFormat:kTwitterPlist, user];
	NSString *path = 
	[_dataPath stringByAppendingPathComponent:plist];
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
											   selector:@selector(_pollFeedForUser:) 
												 object:user];
		[_tweetThread start];
	}
	else 
	{
		_pollOnConnection = YES;
	}
	return twt;
}			
- (void)_pollFeedForUser:(NSString *)user
{
	_tweetPool = [[NSAutoreleasePool alloc] init];
	NSString *url = [NSString stringWithFormat:kFeedAddress, user];
	NSURL *feedURL = [NSURL URLWithString:url];
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
			NSString *plist = [NSString stringWithFormat:kTwitterPlist, user];
			[self _writeToFile:(NSArray *)[tweets copy] withPath:plist];
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
