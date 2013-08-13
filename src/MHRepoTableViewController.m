//
//  MHRepoViewController.m
//  MyHub
//
//  Created by Arcterus on 8/10/13.
//  Copyright (c) 2013 kRaken Research. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "MHRepoTableViewController.h"
#import "MHRepoViewController.h"
#import "MHAppDelegate.h"
#import "OctoKit/OctoKit.h"
#import "ReactiveCocoa/ReactiveCocoa.h"

@interface MHRepoTableViewController ()

- (void)refresh:(UIRefreshControl *)refreshControl;

@end

@implementation MHRepoTableViewController {
	UITableView *_tableView;
	NSMutableArray *_repos;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (id)initWithSelector:(SEL)selector {
	if(self = [super init]) {
		_repos = [[NSMutableArray alloc] init];
		MHAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		OCTClient *client = appDelegate.client;
		[[client performSelector:selector]
		 subscribeNext:^(OCTRepository *repo) {
			 [_repos addObject:repo];
		 } completed:^{
			 NSLog(@"Loaded users repositories");
		 }];
	}
	return self;
}
#pragma clang diagnostic pop

- (id)init {
	return [self initWithSelector:sel_registerName("fetchUserRepositories")];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	CGSize size = self.view.frame.size;
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(.0f, .0f, size.width, size.height) style:UITableViewStylePlain];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.delegate = (id) (_tableView.dataSource = self);
	
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
	
	[_tableView addSubview:refreshControl];
	[self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _repos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
	}
	OCTRepository *repo = [_repos objectAtIndex:indexPath.row];
	cell.textLabel.text = repo.name;
	cell.detailTextLabel.text = repo.repoDescription;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UINavigationController *nav = (UINavigationController *) self.parentViewController;
	[nav pushViewController:[[MHRepoViewController alloc] initWithRepo:[_repos objectAtIndex:indexPath.row]] animated:YES];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
	[refreshControl endRefreshing];
}

- (NSString *)title {
	return @"Repos";
}

@end
