//
//  FSTableViewController.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSViewController.h"
#import "FSTableView.h"


@interface FSTableViewController : FSViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FSTableView *tableView;

@end
