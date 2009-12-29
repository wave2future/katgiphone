//
//  PastShowsTableCellView.h
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

@interface PastShowsTableCellView : UITableViewCell {
	UIImageView *showTypeImageView;
	UILabel     *showTitleLabel;
	UILabel     *showGuestsLabel;
	UIImageView *showNotesImageView;
	UIImageView *showPicsImageView;
}

@property (nonatomic, retain) IBOutlet UIImageView *showTypeImageView;
@property (nonatomic, retain) IBOutlet UILabel     *showTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel     *showGuestsLabel;
@property (nonatomic, retain) IBOutlet UIImageView *showNotesImageView;
@property (nonatomic, retain) IBOutlet UIImageView *showPicsImageView;

@end
