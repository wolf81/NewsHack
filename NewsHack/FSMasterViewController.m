//
//  FSMasterViewController.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSMasterViewController.h"
#import "FSDetailViewController.h"
#import "FSNewsItemViewController.h"
#import "FSNewsLoader.h"
#import "FSNewsCell.h"
#import "FSProfileViewController.h"


#define FS_DATE_NEWS_LAST_LOADED_KEY @"FSDateNewsLastLoadedKey"


@interface FSMasterViewController () <FSTableViewRefreshViewDelegate>

@property (nonatomic, copy) NSArray *items;

- (void)loadDataIgnoringCache:(BOOL)ignoreCache
        withCompletionHandler:(void (^)(BOOL success))completionHandler;
- (void)showProfileViewController;
- (BOOL)shouldReloadNews;
- (void)didReloadNews;

@end


@implementation FSMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"News", @"News");
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}

- (void)dealloc
{
    self.tableView.refreshViewDelegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 50.0f;
    self.tableView.refreshViewDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f);
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:FS_IMAGE_USER style:UIBarButtonItemStylePlain target:self action:@selector(showProfileViewController)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadDataIgnoringCache:[self shouldReloadNews] withCompletionHandler:^ (BOOL success) {
        
        if (success)
        {
            [self didReloadNews];
        }
        
    }];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[FSNewsLoader sharedLoader] cancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    FSNewsCell *cell = (FSNewsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[FSNewsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    cell.newsItem = [_items objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSNewsItem *newsItem = [_items objectAtIndex:indexPath.row];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        FSNewsItemViewController *viewController = [FSNewsItemViewController newsItemViewControllerWithNewsItem:newsItem];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else
    {
        self.detailViewController.detailItem = newsItem;
    }
}

#pragma mark - Table view refresh view delegate

- (void)tableViewRefreshViewDidRefresh:(FSTableView *)tableView
{
    tableView.allowsSelection = NO;
    
    
    FSNewsLoader *newsParser = [FSNewsLoader sharedLoader];
    [newsParser retrieveNewsIgnoringCache:YES withCompletionHandler:^ (FSItemList *newsItems, NSError *error) {
        
        DLog(@"%@ %@", newsItems, error);
        
        if (newsItems)
        {
            [self.tableView updateRefreshDate:newsItems.creationDate];
            self.items = newsItems.items;
            [self.tableView reloadData];
        }
        else
        {
            [self.tableView setFooterText:error.localizedDescription];
        }
        
        tableView.allowsSelection = YES;
        tableView.isRefreshing    = NO;
    }];
}

#pragma mark - Private

- (void)loadDataIgnoringCache:(BOOL)ignoreCache withCompletionHandler:(void (^)(BOOL success))completionHandler
{
    [self showLoadingIndicator:YES];
        
    FSNewsLoader *newsParser = [FSNewsLoader sharedLoader];
    [newsParser retrieveNewsIgnoringCache:ignoreCache withCompletionHandler:^ (FSItemList *newsItems, NSError *error) {

        DLog(@"%@ %@", newsItems, error);

        [self showLoadingIndicator:NO];
       
        if (newsItems)
        {
            [self.tableView updateRefreshDate:newsItems.creationDate];
            self.items = newsItems.items;
            [self.tableView reloadData];
        }
        else
        {            
            [self.tableView setFooterText:error.localizedDescription];
        }
        
        if (completionHandler)
        {
            completionHandler(newsItems != nil);
        }
        
    }];
}

- (void)showProfileViewController
{
    FSProfileViewController *viewController = [[FSProfileViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)shouldReloadNews
{
    NSDate *lastLoadedDate = [[NSUserDefaults standardUserDefaults] objectForKey:FS_DATE_NEWS_LAST_LOADED_KEY];
    NSDate *currentDate = [NSDate date];
    
    return ((lastLoadedDate == nil) ||
            ([currentDate timeIntervalSinceDate:lastLoadedDate] > 60 * 5));
}

- (void)didReloadNews
{
    NSDate *currentDate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setValue:currentDate forKey:FS_DATE_NEWS_LAST_LOADED_KEY];
}

#pragma mark - Public methods

- (void)pushToUserViewController
{
    [self showProfileViewController];
}

@end
