//
//  PastShowsController.h
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

#import <UIKit/UIKit.h>


@interface PastShowsController : UITableViewController <UITableViewDelegate> {
	IBOutlet UINavigationController	*navigationController;
    NSMutableArray					*list;
	UIActivityIndicatorView			*activityIndicator;
	NSMutableArray					*feedEntries;
	NSString						*feedAddress;
}

@property (nonatomic, retain) IBOutlet UINavigationController	*navigationController;
@property (nonatomic, retain) NSMutableArray					*list;
@property (nonatomic, retain) UIActivityIndicatorView			*activityIndicator;
@property (nonatomic, retain) NSMutableArray					*feedEntries;
@property (nonatomic, retain) NSString							*feedAddress;

- (void) pollFeed;

@end
