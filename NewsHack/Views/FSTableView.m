//
//  FSTableView.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/24/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSTableView.h"
#import "EGORefreshTableHeaderView.h"
#import "MessageInterceptor.h"
#import "FSFooterView.h"


@interface FSTableView () <EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{
    NSDate             *_lastRefreshDate;
    MessageInterceptor *_messageInterceptor;
}

@property (nonatomic, strong) EGORefreshTableHeaderView *headerView;
@property (nonatomic, assign) BOOL isHeaderViewVisible;

@end


@implementation FSTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        self.headerView = [[EGORefreshTableHeaderView alloc] init];
        _headerView.delegate = self;
        [_headerView setBackgroundColor:[UIColor whiteColor] textColor:[UIColor blackColor] arrowImage:nil];
        [self hideHeaderView:NO];
        
        self.isRefreshing = NO;
        
        /* Message interceptor to intercept scrollView delegate messages */
        _messageInterceptor = [[MessageInterceptor alloc] init];
        _messageInterceptor.middleMan = self;
        _messageInterceptor.receiver = self.delegate;
        super.delegate = (id)_messageInterceptor;
    }
    return self;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if (_messageInterceptor)
    {
        super.delegate = nil; // <- TODO: can be removed?
        _messageInterceptor.receiver = delegate;
        super.delegate = (id)_messageInterceptor;
    }
    else
    {
        super.delegate = delegate;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _headerView.frame = CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];    
}

+ (FSTableView *)tableView
{
    FSTableView *tableView = [[FSTableView alloc] initWithFrame:CGRectZero];
    if (tableView)
    {
        tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        tableView.separatorColor   = FS_COLOR_BAR;

        CGRect frame = CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, 40.0f);
        tableView.tableFooterView = [FSFooterView footerViewWithFrame:frame];
    }
    return tableView;
}

#pragma mark - Private methods

- (void)setIsRefreshing:(BOOL)isRefreshing
{
    if(!_isRefreshing && isRefreshing) {
        // If not allready refreshing start refreshing
        [_headerView startAnimatingWithScrollView:self];
        _isRefreshing = YES;
    } else if(_isRefreshing && !isRefreshing) {
        [_headerView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        _isRefreshing = NO;
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_headerView superview])
    {
        [_headerView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    // Also forward the message to the real delegate
    if ([_messageInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_messageInterceptor.receiver scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([_headerView superview])
    {
        [_headerView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    // Also forward the message to the real delegate
    if ([_messageInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_messageInterceptor.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_headerView superview])
    {
       [_headerView egoRefreshScrollViewWillBeginDragging:scrollView];
    }
    
    // Also forward the message to the real delegate
    if ([_messageInterceptor.receiver
         respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_messageInterceptor.receiver scrollViewWillBeginDragging:scrollView];
    }
}

#pragma mark -

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    self.isRefreshing = YES;
    
    [_refreshViewDelegate tableViewRefreshViewDidRefresh:self];
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return _lastRefreshDate;
}

- (void)hideHeaderView:(BOOL)hide
{
    if (hide)
    {
        [_headerView removeFromSuperview];
    }
    else
    {
        [self addSubview:_headerView];
    }
}

- (BOOL)isHeaderViewVisible
{
    return ([_headerView superview] != nil);
}

#pragma mark -

- (void)updateRefreshDate:(NSDate *)date;
{
    _lastRefreshDate = date;
    [_headerView refreshLastUpdatedDate];
}

- (void)setFooterText:(NSString *)text
{
    CGFloat height = [FSFooterView heightWithText:text withMaximumWidth:self.bounds.size.width];
    self.tableFooterView = [FSFooterView footerViewWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, height) text:text];
}

@end
