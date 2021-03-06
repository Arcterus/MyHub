//
//  MHRepoViewController.h
//  MyHub
//
//  Created by Arcterus on 8/12/13.
//  Copyright (c) 2013 kRaken Research. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import "OctoKit/OctoKit.h"

@interface MHRepoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithRepo:(OCTRepository *)repo;

@end
