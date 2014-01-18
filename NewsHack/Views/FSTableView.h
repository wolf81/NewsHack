//
//  FSTableView.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/24/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FSTableViewRefreshViewDelegate;

@interface FSTableView : UITableView

@property (nonatomic, assign) id <FSTableViewRefreshViewDelegate> refreshViewDelegate;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign, readonly) BOOL isHeaderViewVisible;

+ (FSTableView *)tableView;
- (void)hideHeaderView:(BOOL)hide;
- (void)updateRefreshDate:(NSDate *)date;
- (void)setFooterText:(NSString *)string;

@end


@protocol FSTableViewRefreshViewDelegate <NSObject>

- (void)tableViewRefreshViewDidRefresh:(FSTableView *)tableView;

@end
