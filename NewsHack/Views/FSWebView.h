//
//  FSWebView.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/31/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FSWebViewRefreshViewDelegate;

@interface FSWebView : UIWebView

@property (nonatomic, assign) id <FSWebViewRefreshViewDelegate> refreshViewDelegate;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign, readonly) BOOL isHeaderViewVisible;

- (void)hideHeaderView:(BOOL)hide;
- (void)updateRefreshDate:(NSDate *)date;
- (void)showError:(NSError *)error;

@end


@protocol FSWebViewRefreshViewDelegate <NSObject>

- (void)webViewRefreshViewDidRefresh:(FSWebView *)webView;

@end
