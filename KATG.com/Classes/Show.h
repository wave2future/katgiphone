//
//  Show.h
//  NSXML
//
//  Created by Doug Russell on 5/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Show : NSObject {
    NSString *title;
	NSString *publishDate;
    NSString *link;
	NSString *detail;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *publishDate;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *detail;

- (id)initWithTitle:(NSString *)theTitle publishDate:(NSString *)thePublishDate link:(NSString *)theLink detail:(NSString *)theDetail;

@end
