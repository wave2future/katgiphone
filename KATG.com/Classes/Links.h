//
//  Links.h
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


@interface Links : NSObject {
    NSString *title;
    NSString *url;
	BOOL inApp;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *url;

- (id)initWithTitle:(NSString *)theTitle withURL:(NSString *)theURL withInApp:(BOOL)theInApp;
-(BOOL)inApp;
-(void)setInApp:(BOOL)inAppValue;

@end
