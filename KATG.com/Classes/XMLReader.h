
#import <Foundation/Foundation.h>


@interface XMLReader : NSObject {
	NSMutableArray *feedEntries;
    NSMutableArray *currentItem;
}

@property (nonatomic, retain) NSMutableArray *feedEntries;
@property (nonatomic, retain) NSMutableArray *currentItem;

- (id)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error;

@end
