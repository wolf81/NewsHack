//
//  FSNewsItemViewController.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSNewsItemViewController.h"
#import "FSCommentsLoader.h"
#import "FSCommentCell.h"
#import "NSAttributedString+Attributes.h"
#import "FSWebViewController.h"
#import "FSTableView.h"
#import "FSMarqueeView.h"
#import "FSCommentMenuCell.h"
#import "FSCommentAddCell.h"
#import "FSPostCommentViewController.h"
#import "FSUserManager.h"
#import "FSAppDelegate.h"
#import "FSWebView.h"


#define FS_TAB_NEWS    0
#define FS_TAB_COMMENT 1


typedef NS_ENUM(NSInteger, FSRequestState)
{
    FSRequestStateError = -1,
    FSRequestStateNotLoaded,
    FSRequestStateIsLoading,
    FSRequestStateFinishedLoading,
};


@interface FSNewsItemViewController ()
<UIWebViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate,
OHAttributedLabelDelegate,
FSCommentMenuCellDelegate,
FSTableViewRefreshViewDelegate,
FSWebViewRefreshViewDelegate>

@property (nonatomic, strong) FSTableView   *tableView;
@property (nonatomic, strong) FSWebView     *webView;
@property (nonatomic, strong) FSMarqueeView *headerView;
@property (nonatomic, strong) FSNewsItem    *newsItem;
@property (nonatomic, copy)   NSArray       *comments;
@property (nonatomic, assign) FSRequestState newsRequestState;
@property (nonatomic, assign) FSRequestState commentRequestState;
@property (nonatomic, strong) NSIndexPath   *menuCellIndex;
@property (nonatomic, assign) BOOL           userCommentsAllowed;

- (void)loadCommentsIgnoreCache:(BOOL)ignoreCache completionHandler:(void (^)(BOOL success))completionHandler;
- (void)loadNews;
- (void)showCommentsTab;
- (void)showNewsTab;
- (void)showNewsLoading:(BOOL)show;
- (void)showCommentsLoading:(BOOL)show;
- (void)segmentedControlTouched:(id)sender;
- (UISegmentedControl *)segmentedControlForTitleView;
- (void)cancel;
- (void)scrollToTableViewRowAtIndexPath:(NSIndexPath *)path;
- (void)openURLInSafari;

- (void)showAlertLoginRequired;
- (void)showPostCommentViewControllerWithItemIdentifier:(NSInteger)identifier;

@end


@implementation FSNewsItemViewController

+ (FSNewsItemViewController *)newsItemViewControllerWithNewsItem:(FSNewsItem *)newsItem
{
    FSNewsItemViewController *viewController = [[FSNewsItemViewController alloc] init];
    if (viewController)
    {
        viewController.newsItem = newsItem;
    }
    return viewController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    if (indexPath)
    {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [_headerView continueAnimation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self cancel];
    
    [_headerView pauseAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.newsRequestState     = FSRequestStateNotLoaded;
    self.commentRequestState  = FSRequestStateNotLoaded;
    self.view.backgroundColor = FS_COLOR_BACKGROUND;
    
    
    CGFloat headerHeight = 30.0f;
    CGRect frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, headerHeight);
    self.headerView = [[FSMarqueeView alloc] initWithFrame:frame];
    _headerView.text = _newsItem.title;
    self.trackedViewName = [NSString stringWithFormat:@"NewsItem: %@", _newsItem.title];
    [self.contentView addSubview:_headerView];
    
    
    // setup tableview for comments ...
    
    frame                          = self.contentView.bounds;
    frame.origin.y                 = _headerView.bounds.size.height;
    frame.size.height             -= _headerView.bounds.size.height;
    self.tableView                 = [FSTableView tableView];
    _tableView.frame               = frame;
    _tableView.dataSource          = self;
    _tableView.separatorStyle      = UITableViewCellSelectionStyleNone;
    _tableView.delegate            = self;
    _tableView.refreshViewDelegate = self;
    _tableView.hidden              = (_newsItem.URL != nil);
    _tableView.refreshViewDelegate = self;
    [self.contentView addSubview:_tableView];
    
    
    // setup title view
    
    if (_newsItem.URL)
    {
        if (_newsItem.commentsEnabled)
        {
            self.navigationItem.titleView = [self segmentedControlForTitleView];
        }
        else
        {
            self.title = NSLocalizedString(@"Promotion", @"Promotion");
        }
        
        // setup webview for news ...
        
        self.webView                 = [[FSWebView alloc] initWithFrame:frame];
        _webView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor     = [UIColor clearColor];
        _webView.delegate            = self;
        _webView.scalesPageToFit     = YES;
        _webView.hidden              = NO;
        _webView.opaque              = NO;
        _webView.refreshViewDelegate = self;
        [self.contentView addSubview:_webView];
        
        [self loadNews];
        [self showNewsTab];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openURLInSafari)];
    }
    else if (_newsItem.commentsEnabled)
    {
        self.title = NSLocalizedString(@"Ask HackerNews", @"Ask HackerNews");
        [self loadCommentsIgnoreCache:NO completionHandler:nil];
        [self showCommentsTab];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    //    [_headerView setLabelize:YES];
}

- (void)dealloc
{
    _webView.delegate = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView.refreshViewDelegate = nil;
    _webView.refreshViewDelegate = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _webView.delegate = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView.refreshViewDelegate = nil;
    _webView.refreshViewDelegate = nil;
    
    self.webView = nil;
    self.tableView = nil;
    self.headerView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

#pragma mark - Edit cell delegate

- (void)cellCommentButtonTouched:(FSCommentMenuCell *)cell
{
    if (_userCommentsAllowed == NO)
    {
        [self showAlertLoginRequired];
        return;
    }
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    FSCommentItem *item = [_comments objectAtIndex:(indexPath.row - 1)];
    [self showPostCommentViewControllerWithItemIdentifier:item.identifier];
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldLoadRequest = (navigationType != UIWebViewNavigationTypeLinkClicked);
    
    if (shouldLoadRequest == NO)
    {
        FSWebViewController *viewController = [FSWebViewController webViewControllerWithURL:request.URL];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    return shouldLoadRequest;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.newsRequestState = FSRequestStateFinishedLoading;

    [_webView updateRefreshDate:[NSDate date]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"%@", error);
    
    if (error.code == NSURLErrorCancelled)
    {
        self.newsRequestState = FSRequestStateFinishedLoading;
    }
    else
    {
        self.newsRequestState = FSRequestStateError;
        [_webView showError:error];
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_headerView pauseAnimation];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_headerView continueAnimation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _comments ? _comments.count + 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    BOOL isLastCell = (indexPath.row == _comments.count);
    
    if (!isLastCell && [indexPath isEqual:_menuCellIndex])
    {
        static NSString *MenuCellIdentifier = @"MenuCellIdentifier";
        
        FSCommentItem *commentItem = [_comments objectAtIndex:indexPath.row - 1];
        
        FSCommentMenuCell *menuCell = (FSCommentMenuCell *)[tableView dequeueReusableCellWithIdentifier:MenuCellIdentifier];
        if (!menuCell)
        {
            menuCell = [[FSCommentMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MenuCellIdentifier];
            menuCell.delegate = self;
        }
        menuCell.indentLevel = commentItem.indentLevel;
        cell = menuCell;
    }
    else if (!isLastCell)
    {
        static NSString *CommentCellIdentifier = @"CommentCellIdentifier";
        
        FSCommentCell *commentCell = (FSCommentCell *)[tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
        if (!commentCell)
        {
            commentCell = [[FSCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentCellIdentifier];
            commentCell.commentLabel.delegate = self;
        }
        
        commentCell.commentItem = [_comments objectAtIndex:indexPath.row];
        
        cell = commentCell;
    }
    else
    {
        static NSString *EditCellIdentifier = @"AddCellIdentifier";
        
        FSCommentAddCell *addCell = (FSCommentAddCell *)[tableView dequeueReusableCellWithIdentifier:EditCellIdentifier];
        if (!addCell)
        {
            addCell = [[FSCommentAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EditCellIdentifier];
        }
        cell = addCell;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _comments.count)
    {
        if (_userCommentsAllowed == NO)
        {
            [self showAlertLoginRequired];
            return;
        }
        
        [self showPostCommentViewControllerWithItemIdentifier:_newsItem.identifier];
    }
    else if (_menuCellIndex) // if currently a menu cell is displayed ...
    {
        // if the pressed cell is either the menu cell or the cell above, close the menu cell ...
        
        if (indexPath.row == _menuCellIndex.row || indexPath.row == (_menuCellIndex.row - 1))
        {
            NSIndexPath *deleteIndex = [_menuCellIndex copy];
            self.menuCellIndex = nil;
            
            NSMutableArray *array = [_comments mutableCopy];
            [array removeObjectAtIndex:deleteIndex.row];
            self.comments = array;
            
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[deleteIndex] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
        else // if any other cell pressed, close existing menu cell and open new menu cell for pressed cell ...
        {
            int rowIndex = indexPath.row < _menuCellIndex.row ? indexPath.row + 1 : indexPath.row;
            NSIndexPath *insertIndex = [NSIndexPath indexPathForRow:rowIndex inSection:indexPath.section];
            NSIndexPath *deleteIndex = [_menuCellIndex copy];
            
            NSMutableArray *array = [_comments mutableCopy];
            [array removeObjectAtIndex:deleteIndex.row];
            
            FSCommentItem *item = [[FSCommentItem alloc] init];
            if (indexPath.row != array.count)
            {
                [array insertObject:item atIndex:insertIndex.row];
            }
            else
            {
                [array addObject:item];
            }
            self.comments = array;
            
            self.menuCellIndex = insertIndex;
            
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:@[insertIndex] withRowAnimation:UITableViewRowAnimationFade];
            [tableView deleteRowsAtIndexPaths:@[deleteIndex] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
            
            [self performSelector:@selector(scrollToTableViewRowAtIndexPath:) withObject:_menuCellIndex afterDelay:0.1f];
        }
    }
    else
    {
        NSIndexPath *insertIndex = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section];
        self.menuCellIndex = insertIndex;
        
        NSMutableArray *array = [_comments mutableCopy];
        FSCommentItem *item = [[FSCommentItem alloc] init];
        if (indexPath.row != array.count)
        {
            [array insertObject:item atIndex:insertIndex.row];
        }
        else
        {
            [array addObject:item];
        }
        self.comments = array;
        
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:@[insertIndex] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
        [self performSelector:@selector(scrollToTableViewRowAtIndexPath:) withObject:_menuCellIndex afterDelay:0.1f];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    
    BOOL isLastCell = (indexPath.row == _comments.count);
    
    FSCommentItem *item = !isLastCell ? [_comments objectAtIndex:indexPath.row] : nil;
    if ((_menuCellIndex && _menuCellIndex.row == indexPath.row) || isLastCell)
    {
        height = 40.0f;
    }
    else
    {
        CGFloat width = self.view.bounds.size.width - (FS_FLOAT_PADDING * 2) - (item.indentLevel * 10.0f);
        CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
        
        NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:item.text];
        [string setFont:FS_FONT_SMALL];
        CGSize size = [string sizeConstrainedToSize:constraint];
        height += size.height;
        
        size = [item.poster sizeWithFont:FS_FONT_SMALL constrainedToSize:constraint lineBreakMode:NSLineBreakByTruncatingTail];
        height += size.height + FS_FLOAT_PADDING * 2;
    }
    
    return height;
}

- (void)scrollToTableViewRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


#pragma mark - Attributed label delegate

- (BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    DLog(@"%@", linkInfo.URL);
    
    FSWebViewController *viewController = [FSWebViewController webViewControllerWithURL:linkInfo.URL];
    [self.navigationController pushViewController:viewController animated:YES];
    
    return NO;
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [FSAppDelegate navigateToUserViewController];
    }
    else
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

#pragma mark - Web view refresh view delegate

- (void)webViewRefreshViewDidRefresh:(FSWebView *)webView
{
    [self loadNews];
}

#pragma mark - Table view refresh view delegate

- (void)tableViewRefreshViewDidRefresh:(FSTableView *)tableView
{
    tableView.allowsSelection = NO;
    
    [self loadCommentsIgnoreCache:YES completionHandler:^ (BOOL success) {
        
        tableView.allowsSelection = YES;
        tableView.isRefreshing    = NO;
    }];
}

#pragma mark - Private methods

- (void)showAlertLoginRequired
{
    NSString *title       = NSLocalizedString(@"Login required", nil);
    NSString *message     = NSLocalizedString(@"You need to be logged in to post comments. Would you like to login now?", nil);
    NSString *buttonTitle = NSLocalizedString(@"OK", nil);
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:buttonTitle, nil];
    [alert show];
}

- (void)segmentedControlTouched:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    switch (segmentedControl.selectedSegmentIndex)
    {
        case FS_TAB_COMMENT: [self showCommentsTab]; break;
        case FS_TAB_NEWS:    [self showNewsTab];     break;
        default: break;
    }
}

- (UISegmentedControl *)segmentedControlForTitleView
{
    UIImage *newsImage = FS_IMAGE_NEWS;
    UIImage *chatImage = FS_IMAGE_CHAT_LIGHT;
    
    UISegmentedControl *segmentedControl   = [[UISegmentedControl alloc] initWithItems:@[newsImage, chatImage]];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.tintColor             = FS_COLOR_BAR;
    segmentedControl.frame                 = CGRectMake(0.0f, 0.0f, 100.0f, 30.0f);
    segmentedControl.selectedSegmentIndex  = 0;
    segmentedControl.autoresizingMask      = UIViewAutoresizingFlexibleHeight;
    [segmentedControl addTarget:self action:@selector(segmentedControlTouched:) forControlEvents:UIControlEventValueChanged];
    
    return segmentedControl;
}

- (void)showCommentsTab
{
    _tableView.hidden                = NO;
    _webView.hidden                  = YES;
    _tableView.scrollsToTop          = YES;
    _webView.scrollView.scrollsToTop = NO;
    
    switch (_commentRequestState)
    {
        case FSRequestStateNotLoaded: [self loadCommentsIgnoreCache:NO completionHandler:nil]; break;
        case FSRequestStateError: [self showCommentsLoading:NO]; break;
        case FSRequestStateIsLoading: [self showCommentsLoading:YES]; break;
        case FSRequestStateFinishedLoading: [self showCommentsLoading:NO]; break;
        default: break;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)showNewsTab
{
    _tableView.hidden                = YES;
    _webView.hidden                  = NO;
    _webView.scrollView.scrollsToTop = YES;
    _tableView.scrollsToTop          = NO;
    
    switch (_newsRequestState)
    {
        case FSRequestStateNotLoaded: [self loadNews]; break;
        case FSRequestStateIsLoading: [self showNewsLoading:YES]; break;
        case FSRequestStateError: [self showNewsLoading:NO]; break;
        case FSRequestStateFinishedLoading: [self showNewsLoading:NO]; break;
        default: break;
    }

    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)loadCommentsIgnoreCache:(BOOL)ignoreCache completionHandler:(void (^)(BOOL success))completionHandler
{
    self.commentRequestState = FSRequestStateIsLoading;
    
    FSCommentsLoader *commentsLoader = [FSCommentsLoader sharedLoader];
    [commentsLoader retrieveCommentsWithNewsItem:_newsItem ignoreCache:ignoreCache completionHandler:^ (FSItemList *commentList, NSError *error) {
                
        FSProfileInfo *profile = [[FSUserManager sharedManager] currentProfile];
        self.userCommentsAllowed = (profile != nil);
        DLog(@"user may place comments? %@", profile ? @"YES" : @"NO");
        
        if (commentList)
        {
            self.commentRequestState = FSRequestStateFinishedLoading;
            self.comments = commentList.items;
            [self.tableView updateRefreshDate:commentList.creationDate];
            [self.tableView reloadData];
        }
        else
        {
            DLog(@"%@", error);
            self.commentRequestState = FSRequestStateError;
            [self.tableView setFooterText:error.localizedDescription];
        }
        
        if (completionHandler)
        {
            completionHandler(commentList != nil);
        }
    }];
}

- (void)loadNews
{    
    NSURLRequest *request = [NSURLRequest requestWithURL:_newsItem.URL];
    [_webView loadRequest:request];
    
    self.newsRequestState = FSRequestStateIsLoading;
}

- (void)cancel
{
    [[FSCommentsLoader sharedLoader] cancel];
    [_webView stopLoading];
}

- (void)showPostCommentViewControllerWithItemIdentifier:(NSInteger)identifier
{
    FSPostCommentViewController *viewController = [[FSPostCommentViewController alloc] initWithItemIdentifier:identifier];
    viewController.completionHandler = ^ (BOOL finished) {
        
        if (finished)
        {
            int64_t delayInSeconds = 1.0f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self loadCommentsIgnoreCache:YES completionHandler:nil];
            });
        }
    };
    
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:viewController animated:YES completion:nil];
    
}

#pragma mark - State handling

- (void)setCommentRequestState:(FSRequestState)commentRequestState
{
    if (_commentRequestState == commentRequestState)
    {
        return;
    }
    
    _commentRequestState = commentRequestState;
    
    switch (_commentRequestState)
    {
            // show loading indicator ...
        case FSRequestStateIsLoading: [self showCommentsLoading:YES]; break;
            
            // hide loading indicator ...
        case FSRequestStateFinishedLoading:
        case FSRequestStateError: [self showCommentsLoading:NO]; break;

            // don't do anything ...
        case FSRequestStateNotLoaded:
        default: break;
    }
}

- (void)setNewsRequestState:(FSRequestState)newsRequestState
{
    if (_newsRequestState == newsRequestState)
    {
        return;
    }
    
    _newsRequestState = newsRequestState;
        
    switch (_newsRequestState)
    {
            // show loading indicator ...
        case FSRequestStateIsLoading: [self showNewsLoading:YES]; break;
            
            // hide loading indicator ...
        case FSRequestStateFinishedLoading:
        case FSRequestStateError: [self showNewsLoading:NO]; break;

            // don't do anything ...
        case FSRequestStateNotLoaded:
        default: break;
    }
}

- (void)showCommentsLoading:(BOOL)show
{
    if (show)
    {
        [self showLoadingIndicator:YES forView:_tableView];
    }
    else
    {
        [self showLoadingIndicator:NO forView:_tableView];
    }
}

- (void)showNewsLoading:(BOOL)show
{
    if (show)
    {
        [self showLoadingIndicator:(_webView.isRefreshing == NO) forView:_webView];
    }
    else
    {
        self.webView.isRefreshing = NO;
        [self showLoadingIndicator:NO forView:_webView];
    }
}

- (void)openURLInSafari
{
    if ([[UIApplication sharedApplication] canOpenURL:_newsItem.URL])
    {
        [[UIApplication sharedApplication] openURL:_newsItem.URL];
    }
    else
    {
        DLog(@"WARNING: can't open URL: %@", _newsItem.URL);
    }
}

@end
