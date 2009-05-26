//
//  extractURL.h
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

#import <Foundation/Foundation.h>


@interface extractURL : NSObject {
	NSMutableArray	*urlList;
	NSMutableArray	*urlArray;
	NSString		*urlAddress;
}

@property (nonatomic, retain) NSMutableArray	*urlList;
@property (nonatomic, retain) NSMutableArray	*urlArray;
@property (nonatomic, retain) NSString			*urlAddress;

- (id)makeURLList:(NSString *)tweetString;
- (id)makeURL:(NSString *)tweetString;

@end
