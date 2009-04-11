//
//  Event.h
//  CustomTableCells
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


@interface Event : NSObject {
    NSString *title;
    NSString *publishDate;
    NSString *type;
	NSString *detail;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *publishDate;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *detail;

- (id)initWithTitle:(NSString *)theTitle publishDate:(NSString *)thePublishDate type:(NSString *)theType detail:(NSString *)theDetail;

@end
