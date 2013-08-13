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

@interface MHRepoViewController ()

@end

@implementation MHRepoViewController {
	OCTRepository *_repo;
}

- (id)initWithRepo:(OCTRepository *)repo {
	if(self = [super init]) {
		_repo = repo;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSString *)title {
	return _repo.name;
}

@end