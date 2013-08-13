//
//  MHMainViewController.m
//  MyHub
//
//  Created by Arcterus on 8/10/13.
//  Copyright (c) 2013 kRaken Research. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "MHMainViewController.h"
#import "MHHomeViewController.h"
#import "MHRepoTableViewController.h"
#import "MHStarredRepoTableViewController.h"
#import "MHSettingsViewController.h"

@interface MHMainViewController ()

@end

@implementation MHMainViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	[self setViewControllers:@[[[MHHomeViewController alloc] init],
										[[UINavigationController alloc] initWithRootViewController:[[MHRepoTableViewController alloc] init]],
										[[UINavigationController alloc] initWithRootViewController:[[MHStarredRepoTableViewController alloc] init]],
										[[MHSettingsViewController alloc] init]] animated:YES];
	self.selectedIndex = 0;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
