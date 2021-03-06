//
//  LinksViewController.h
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

#import "LinksDataModel.h"

@interface LinksViewController : UIViewController <LinksModelDelegate, UITableViewDelegate> {
	id delegate;
	NSNumber *shouldStream;
	
	UIButton *infoButton;
	UITableView *tblView;
	NSArray *list;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UITableView *tblView;

- (IBAction)infoSheet;

@end
