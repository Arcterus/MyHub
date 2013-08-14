//
//  MHSortOptionViewController.m
//  MyHub
//
//  Created by Arcterus on 8/13/13.
//  Copyright (c) 2013 kRaken Research. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "MHSortOptionViewController.h"
#import "MHRepoTableViewController.h"
#import "OctoKit/OctoKit.h"

#define SORT_DATE 0
#define SORT_NAME 1
#define NUM_OPTIONS 2

@interface MHSortOptionViewController ()

@end

@implementation MHSortOptionViewController

static NSString *options[NUM_OPTIONS] = { @"Sort by Date", @"Sort by Name" };

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	CGSize cellSize = [[UITableViewCell alloc] init].frame.size;
	CGSize size = CGSizeMake(cellSize.width / 2, cellSize.height * NUM_OPTIONS);
	
	self.preferredContentSize = size;

	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(.0f, .0f, size.width, size.height) style:UITableViewStylePlain];
	tableView.delegate = (id) (tableView.dataSource = self);
	
	[self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return NUM_OPTIONS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
	}
	cell.textLabel.text = options[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch(indexPath.row) {
		case SORT_DATE:
		case SORT_NAME:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"sortRepos" object:indexPath];
	}
}

@end
