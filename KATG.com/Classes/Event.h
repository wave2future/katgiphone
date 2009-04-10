//
//  Movie.h
//  CustomTableCells
//
//  Created by Atrexis on 05/01/09.
//  Copyright 2009 Atrexis Systems Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Event : NSObject {
    NSString *title;
    NSString *publishDate;
    NSString *type;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *publishDate;
@property (nonatomic, retain) NSString *type;

- (id)initWithTitle:(NSString *)theTitle publishDate:(NSString *)thePublishDate type:(NSString *)theType;

@end
