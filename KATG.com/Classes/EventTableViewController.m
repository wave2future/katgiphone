//
//  EventTableViewController.m
//  KATG.com
//
//  Copyright 2009 Doug Russell
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "EventTableViewController.h"
#import "EventTableCellView.h"
#import "EventDetailViewController.h"

@implementation EventTableViewController

@synthesize navigationController;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self.tableView setRowHeight:80.0];
	
	[self getEventsData];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc 
{
	[navigationController release];
	[list release];
    [super dealloc];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"EventTableCell";
    static NSString *CellNib = @"EventTableCellView";
	
    EventTableCellView *cell = (EventTableCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
        cell = (EventTableCellView *)[nib objectAtIndex:0];
    }
	
    [[cell eventTitleLabel] setText:[[list objectAtIndex:indexPath.row] objectForKey:@"Title"]];
	[[cell eventDayLabel] setText:[[list objectAtIndex:indexPath.row] objectForKey:@"Day"]];
	[[cell eventDateLabel] setText:[[list objectAtIndex:indexPath.row] objectForKey:@"Date"]];
	[[cell eventTimeLabel] setText:[[list objectAtIndex:indexPath.row] objectForKey:@"Time"]];
	
	if ([[[list objectAtIndex:indexPath.row] objectForKey:@"ShowType"] boolValue]) {
		[[cell eventTypeImageView] setImage:[UIImage imageNamed:@"LiveShowIconTrans.png"]];
	} else {
		[[cell eventTypeImageView] setImage:[UIImage imageNamed:@"EventIconTrans.png"]];
	}
	
	/*if (indexPath.row % 2 == 0) {
	 [(UIImageView *)[cell backgroundView] setImage:[UIImage imageNamed:@"CellBackgroundDark80.png"]];
	 }*/
	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	EventDetailViewController *eventDetailViewController = 
	[[EventDetailViewController alloc] initWithNibName:@"EventDetailView" bundle:nil];
	eventDetailViewController.event = [[list objectAtIndex:indexPath.row] copy];
	[self.navigationController pushViewController:eventDetailViewController animated:YES];
	[eventDetailViewController release];
}

- (void)reloadTableView 
{
	if ([NSThread isMainThread]) {
		[self.tableView reloadData];
	} else {
		[self performSelectorOnMainThread:@selector(reloadTableView) 
							   withObject:nil 
							waitUntilDone:NO];
	}
}

- (void)getEventsData 
{
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(eventsDataModelDidChangeNotification:)
	 name:@"EventsModelDidChange" 
	 object:nil];
	EventsDataModel *model = [EventsDataModel sharedEventsDataModel];
	list = [model eventsFromDisk];
}

- (void)eventsDataModelDidChangeNotification:(NSNotification *)notification 
{
	list = [notification object];
	[self reloadTableView];
}

@end


