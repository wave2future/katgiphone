//
//  SecondViewController.h
//  KATG.com
//  
//  This currently loads keithandthegirl.com/events
//  It will be replaced with a table view
//  generated from an xml feed of the events page
//  
//  Created by Doug Russell on 4/5/09.
//  Copyright Radio Dysentery 2009. All rights reserved.
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

@interface SecondViewController : UITableViewController {
    NSMutableArray *list;
	NSMutableArray *feedEntries;
}

@end