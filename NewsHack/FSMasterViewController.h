//
//  FSMasterViewController.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTableViewController.h"


@class FSDetailViewController;

@interface FSMasterViewController : FSTableViewController

@property (strong, nonatomic) FSDetailViewController *detailViewController;

- (void)pushToUserViewController;

@end
