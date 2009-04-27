//
//  Event.m
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

#import "Event.h"
#import "MREntitiesConverter.h"

@implementation Event

@synthesize title, publishTime, publishDate, type, detail;

// Creates the object with primary key and title is brought into memory.
- (id)initWithTitle:(NSString *)theTitle publishTime:(NSString *)thePublishTime publishDate:(NSString *)thePublishDate type:(NSString *)theType detail:(NSString *)theDetail {
    MREntitiesConverter *converter = [[MREntitiesConverter alloc] init];
	
	if (self = [super init]) {
        title = [[NSString alloc] initWithString:theTitle];
        publishTime = [[NSString alloc] initWithString:thePublishTime];
		publishDate = [[NSString alloc] initWithString:thePublishDate];
        type = [[NSString alloc] initWithString:theType];
		detail = [converter convertEntitiesInString:[[NSString alloc] initWithString:theDetail]];
    }
	
    return self;
}

- (void)dealloc {
    [title release];
    [publishTime release];
	[publishDate release];
    [type release];
	[detail release];
    [super dealloc];
}

@end

