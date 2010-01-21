//
//  TwitterSingleDataModel+PrivateMethods.h
//  KATG.com
//
//  Created by Doug Russell on 1/20/10.
//  Copyright 2010 Paper Software. All rights reserved.
//

#import "TwitterSingleDataModel.h"

@class CXMLElement;
@interface TwitterSingleDataModel (PrivateMethods)

- (NSArray *)_getTweetsForUser:(NSString *)user;
- (void)_cancelTweets;
- (void)_stopTweetsThread;
- (void)_pollFeedForUser:(NSString *)user;
- (id)_processElement:(CXMLElement *)element forName:(NSString *)name;
- (UIImage *)_getImage:(NSURL *)imageURL forIndexPath:(NSIndexPath *)indexPath;
- (void)downloadImage:(NSURL *)imageURL forIndexPath:(NSIndexPath *)indexPath;
- (void)addToImagesDictionary:(NSArray *)array;

@end
