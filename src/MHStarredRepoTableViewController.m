//
//  MHStarredRepoTableViewController.m
//  MyHub
//
//  Created by Arcterus on 8/12/13.
//  Copyright (c) 2013 kRaken Research. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "MHStarredRepoTableViewController.h"

@interface MHStarredRepoTableViewController ()

@end

@implementation MHStarredRepoTableViewController

- (id)init {
	return [super initWithSelector:sel_registerName("fetchUserStarredRepositories")];
}

- (NSString *)title {
	return @"Starred";
}

@end
