//
//  MHRepoViewController.m
//  MyHub
//
//  Created by Arcterus on 8/12/13.
//  Copyright (c) 2013 kRaken Research. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "MHRepoViewController.h"
#import "MHAppDelegate.h"
#import "SVProgressHUD.h"
#import "Bypass.h"
#include <resolv.h>

#define INFO_SECTION 0
#define CODE_SECTION 1

@interface MHRepoViewController ()

- (void)initSubviews;
- (void)refresh:(UIRefreshControl *)refreshControl;
- (NSString *)b64decode:(NSString *)encoded;

@property (strong, nonatomic) OCTFileContent *readme;

@end

@implementation MHRepoViewController {
	OCTRepository *_repo;
	NSMutableArray *_files;
	OCTFileContent *_readme;
	UITableView *_tableView;
}

@synthesize readme = _readme;

- (id)initWithRepo:(OCTRepository *)repo {
	if(self = [super init]) {
		_repo = repo;
		_files = [NSMutableArray array];
		MHAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		OCTClient *client = appDelegate.client;
		[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
		[[RACObserve(self, readme) skip:1] subscribeNext:^(OCTFileContent *content) {
			if(content.content == nil) return;
			CGSize size = self.view.frame.size;
			BPMarkdownView *readmeView = [[BPMarkdownView alloc] initWithFrame:CGRectMake(.0f, .0f, size.width, size.height / 2) markdown:[self b64decode:content.content]];
			/*[[client enqueueRequest:[client requestWithMethod:@"POST" path:@"/markdown" parameters:[NSDictionary dictionaryWithObject:[self b64decode:content.content] forKey:@"text"]] resultClass:[NSString class]] subscribeNext:^(NSString *markdown) {*/
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					//UIWebView *readmeView = [[UIWebView alloc] initWithFrame:CGRectMake(.0f, .0f, size.width, size.height / 2)];
					//[readmeView loadHTMLString:markdown baseURL:repo.HTMLURL];
					_tableView.tableFooterView = readmeView;
					[_tableView reloadData];
				}];
			//}];
		}];
		[[[client fetchRelativePath:nil inRepository:repo reference:nil]
		 flattenMap:^RACStream *(OCTContent *file) {
			 if([file isKindOfClass:[OCTDirectoryContent class]]) {
				 return [RACSignal return:file];
			 } else {
				 // XXX: failing?
				 return [client fetchRelativePath:file.name inRepository:repo reference:nil];
			 }
		 }]
		 subscribeNext:^(OCTContent *file) {
			 NSString *lower = [file.name lowercaseString];
			 if([file isKindOfClass:[OCTFileContent class]] &&
					([lower isEqualToString:@"readme.md"] ||
					 [lower isEqualToString:@"readme.markdown"] ||
					 [lower isEqualToString:@"readme.mdown"])) {
				 self.readme = (OCTFileContent *) file;
			 }
			 [_files addObject:file];
		 } completed:^{
			 [_files sortUsingComparator:^NSComparisonResult(OCTContent *obj1, OCTContent *obj2) {
				 if([obj1 isKindOfClass:[OCTDirectoryContent class]]) {
					 return NSOrderedAscending;
				 } else if([obj2 isKindOfClass:[OCTDirectoryContent class]]) {
					 return NSOrderedDescending;
				 }
				 return [obj1.name compare:obj2.name];
			 }];
			 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
				 [SVProgressHUD dismiss];
				 [_tableView reloadData];
			 }];
			 NSLog(@"Loaded repo files");
		 }];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	[self initSubviews];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case INFO_SECTION:
			return 0;
		case CODE_SECTION:
			return [_files count];
		default:
			return 0;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case INFO_SECTION:
			return @"Information";
		case CODE_SECTION:
			return @"Code";
		default:
			return @"";
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
	}
	switch(indexPath.section) {
		case INFO_SECTION:
			break;
		case CODE_SECTION: {
			cell.accessoryType = UITableViewCellAccessoryNone;
			OCTContent *content = [_files objectAtIndex:indexPath.row];
			cell.textLabel.text = content.name;
			if([content isKindOfClass:[OCTFileContent class]]) {
				float size = content.size;
				enum { B, K, M, G } type = B;  // if you've got a terabyte-sized file on GitHub, there's something wrong with you.
				while(size > 1024) {
					size /= 1024;
					type++;
				}
				char filetype[2];
				switch(type) {
					case K:
						filetype[0] = 'K';
						break;
					case M:
						filetype[0] = 'M';
						break;
					case G:
						filetype[0] = 'G';
						break;
					default:
						filetype[0] = '?';
						filetype[1] = '?';
				}
				if(type == B) {
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d B", content.size];
				} else {
					if(type <= G) {
						filetype[1] = 'B';
					}
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f %c%c", size, filetype[0], filetype[1]];
				}
			} else if([content isKindOfClass:[OCTDirectoryContent class]]) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.detailTextLabel.text = @"Directory";
			} else if([content isKindOfClass:[OCTSymlinkContent class]]) {
				OCTSymlinkContent *symlink = (OCTSymlinkContent *) content;
				cell.detailTextLabel.text = symlink.target;
			} else if([content isKindOfClass:[OCTSubmoduleContent class]]) {
				OCTSubmoduleContent *submodule = (OCTSubmoduleContent *) content;
				cell.detailTextLabel.text = submodule.submoduleGitURL;
			}
		}
	}
	return cell;
}

- (NSString *)title {
	return [NSString stringWithFormat:@"%@/%@", _repo.ownerLogin, _repo.name];
}

- (void)initSubviews {
	CGSize size = self.view.frame.size;
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(.0f, .0f, size.width, size.height) style:UITableViewStyleGrouped];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[_tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
	/*if(_readme != nil) {
		BPMarkdownView *readmeView = [[BPMarkdownView alloc] initWithFrame:CGRectMake(.0f, .0f, size.width, size.height / 2) markdown:_readme.content];
		_tableView.tableFooterView = readmeView;
	}*/
	_tableView.delegate = (id) (_tableView.dataSource = self);
	
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
	
	[_tableView addSubview:refreshControl];
	[self.view addSubview:_tableView];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
	[_tableView reloadData];
	[refreshControl endRefreshing];
}

- (NSString *)b64decode:(NSString *)encoded {
	NSUInteger buffer_len = encoded.length * 3 / 4;
	uint8_t *buffer = (uint8_t *) malloc(buffer_len);
	b64_pton([encoded UTF8String], buffer, buffer_len);
	NSString *result = [NSString stringWithUTF8String:(const char *) buffer];
	free(buffer);
	return result;
}

@end
