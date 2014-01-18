//
//  FSProfileViewController.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/26/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSProfileViewController.h"
#import "FSInfoViewController.h"
#import "DejalActivityView.h"
#import "FSProfileViewCell.h"
#import "FSProductStore.h"
#import "FSProfileLoader.h"
#import "FSMarqueeView.h"
#import "FSTransaction.h"
#import "EGOCache.h"


#define FS_SECTION_SETTINGS 1
#define FS_SECTION_PROFILE  0


typedef NS_ENUM(NSInteger, FSAlertTag) {
    FSAlertTagLogin = 1000,
    FSAlertTagRegister,
    FSAlertTagClearCache,
};


@interface FSProfileViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) FSProfileInfo *profileInfo;

- (void)showInfoViewController;
- (void)reloadTableViewSection:(NSInteger)section;

- (NSString *)textForSettingsSectionRow:(NSInteger)row;
- (NSString *)textForProfileSectionRow:(NSInteger)row;
- (NSString *)titleForSection:(NSInteger)section;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)registerWithUsername:(NSString *)username password:(NSString *)password;
- (void)logout;
- (void)disableAds;
- (void)emptyCache;

- (void)tableViewDidSelectProfileSectionRow:(NSInteger)row;
- (void)tableViewDidSelectSettingsSectionRow:(NSInteger)row;

@end


@implementation FSProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"User", @"User");
    }
    return self;
}

- (void)dealloc
{
    [[FSProductStore defaultStore] cancelProductRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.sectionHeaderHeight = FS_FLOAT_SECTION_HEADER_HEIGHT;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.separatorStyle      = UITableViewCellSeparatorStyleNone;
    [self.tableView hideHeaderView:YES];
    
    self.profileInfo = [FSProfileInfo load];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showInfoViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[FSProfileLoader sharedLoader] cancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    FSProfileViewCell *cell = (FSProfileViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[FSProfileViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *text = nil;
    
    switch (indexPath.section)
    {
        case FS_SECTION_SETTINGS: text = [self textForSettingsSectionRow:indexPath.row]; break;
        case FS_SECTION_PROFILE:  text = [self textForProfileSectionRow:indexPath.row];  break;
        default: break;
    }
    
    cell.title = text;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    
    switch (section)
    {
        case FS_SECTION_PROFILE:  rowCount = [FSProfileInfo load] ? 1 : 2; break;
        case FS_SECTION_SETTINGS: rowCount = [FSTransaction load] ? 1 : 2; break;
        default: break;
    }
    
    return rowCount;
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    const CGRect bounds = self.view.bounds;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, bounds.size.width, 1)];
    view.backgroundColor = FS_COLOR_BAR;
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    const CGRect bounds = self.view.bounds;
    
    CGRect frame = CGRectMake(0.0f, 0.0f, bounds.size.width, FS_FLOAT_SECTION_HEADER_HEIGHT);
    FSMarqueeView *headerView = [[FSMarqueeView alloc] initWithFrame:frame];
    headerView.text = [self titleForSection:section];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case FS_SECTION_PROFILE:  [self tableViewDidSelectProfileSectionRow:indexPath.row];  break;
        case FS_SECTION_SETTINGS: [self tableViewDidSelectSettingsSectionRow:indexPath.row]; break;
        default: break;
    }
}

#pragma mark - Private methods

- (void)showInfoViewController
{
    FSInfoViewController *viewController = [[FSInfoViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (NSString *)textForSettingsSectionRow:(NSInteger)row
{
    NSString *text = nil;
    
    switch (row)
    {
        case 0: text = @"Empty Cache"; break;
        case 1: text = @"Remove Ads"; break;
        case 2: text = @"... color scheme ..."; break;
        case 3: text = @"... open links in external browser ..."; break;
        default: break;
    }
    
    return text;
}

- (NSString *)textForProfileSectionRow:(NSInteger)row
{
    NSString *text = nil;
    
    switch (row)
    {
        case 0: text = _profileInfo ? [NSString stringWithFormat:@"Logout (%@)", _profileInfo.username] : @"Login"; break;
        case 1: text = @"Register"; break;
        case 2: text = @"... comment history ..."; break;
        default: break;
    }
    
    return text;
}

- (NSString *)titleForSection:(NSInteger)section
{
    NSString *text = nil;
    
    switch (section)
    {
        case FS_SECTION_SETTINGS: text = NSLocalizedString(@"Settings", @"Settings"); break;
        case FS_SECTION_PROFILE:  text = NSLocalizedString(@"HackerNews Profile", nil);   break;
        default: break;
    }
    
    return text;
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) // cancel pressed ...
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case FSAlertTagLogin:
        {
            if (buttonIndex == 1)
            {
                NSString *username = [alertView textFieldAtIndex:0].text;
                NSString *password = [alertView textFieldAtIndex:1].text;
                                
                [self loginWithUsername:username password:password];
            }
            
        } break;
            
        case FSAlertTagRegister:
        {
            if (buttonIndex == 1)
            {
                NSString *username = [alertView textFieldAtIndex:0].text;
                NSString *password = [alertView textFieldAtIndex:1].text;
                
                [self registerWithUsername:username password:password];
            }
            
        } break;
            
        default: break;
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    BOOL buttonEnabled = YES;
    
    switch (alertView.tag)
    {
        case FSAlertTagLogin:
        {
            buttonEnabled = ([alertView textFieldAtIndex:0].text.length > 0 &&
                             [alertView textFieldAtIndex:1].text.length > 0);
        } break;

        case FSAlertTagRegister:
        {
            buttonEnabled = ([alertView textFieldAtIndex:0].text.length > 0 &&
                             [alertView textFieldAtIndex:1].text.length > 0);
        } break;

        default: break;
    }
    
    return buttonEnabled;
}

#pragma mark - Private

- (void)registerWithUsername:(NSString *)username password:(NSString *)password
{
    [self showLoadingIndicator:YES];
    
    FSProfileLoader *profileLoader = [FSProfileLoader sharedLoader];
    [profileLoader registerWithUsername:username password:password completionHandler:^ (BOOL success, NSError *error) {

        [self showLoadingIndicator:NO];
        
        if (success)
        {
            [self loginWithUsername:username password:password];
        }
        else
        {
            [UIAlertView showAlertViewWithError:error delegate:self];
        }
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    [self showLoadingIndicator:YES];
    
    FSProfileLoader *profileLoader = [FSProfileLoader sharedLoader];
    [profileLoader loginWithUsername:username password:password completionHandler:^ (FSProfileInfo *profileInfo, NSError *error) {
        
        DLog(@"%@ %@", profileInfo, error);
        
        [self showLoadingIndicator:NO];

        if (profileInfo)
        {
            [profileInfo store];
            self.profileInfo = profileInfo;
            [[EGOCache globalCache] clearCache];
            
            [self reloadTableViewSection:FS_SECTION_PROFILE];
        }
        else // handle error ...
        {            
            [UIAlertView showAlertViewWithError:error delegate:self];
        }
    }];
}

- (void)logout
{
    [self showLoadingIndicator:YES];
    
    FSProfileLoader *profileLoader = [FSProfileLoader sharedLoader];
    [profileLoader logoutWithCompletionHandler:^ (BOOL success, NSError *error) {
        
        DLog(@"%d %@", success, error);

        [self showLoadingIndicator:NO];
        
        if (success)
        {
            // TODO: do we actually need to clear cache here ...? Perhaps only at login?
            
            [FSProfileInfo clear];
            self.profileInfo = nil;

            [self reloadTableViewSection:FS_SECTION_PROFILE];
        }
        else // handle error ...
        {
            [UIAlertView showAlertViewWithError:error delegate:nil];
        }
        
    }];
}

- (void)reloadTableViewSection:(NSInteger)section
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableViewDidSelectProfileSectionRow:(NSInteger)row
{
    switch (row)
    {
        case 0:
        {
            if (_profileInfo)
            {
                [self logout];
            }
            else
            {
                NSString *title = NSLocalizedString(@"Login", nil);
                NSString *message = @"Enter your username & password";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
                alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                alertView.tag = FSAlertTagLogin;
                [alertView show];
            }
            
        } break;
            
        case 1:
        {
            NSString *title = NSLocalizedString(@"Register", nil);
            NSString *message = @"Choose a username & password";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Register", nil), nil];
            alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            alertView.tag = FSAlertTagRegister;
            [alertView show];
            
        } break;
            
        default: break;
    }
}

- (void)tableViewDidSelectSettingsSectionRow:(NSInteger)row
{
    switch (row)
    {
        case 0: [self emptyCache]; break;
        case 1: [self disableAds]; break;
        default: break;
    }
}

- (void)disableAds
{
    [self showLoadingIndicator:YES forView:self.tableView];
    
    [[FSProductStore defaultStore] startProductRequestWithIdentifier:FS_PRODUCT_DISABLE_ADS completionHandler:^ (BOOL success, NSError *error) {
    
        [self showLoadingIndicator:NO forView:self.tableView];
        
        DLog(@"%d %@", success, error);

        if (success)
        {
            NSNumber *object = [NSNumber numberWithBool:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:FSShouldDisableAdsNotification object:object];
            
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            if (indexPath)
            {
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
        else if (error)
        {
            [UIAlertView showAlertViewWithError:error delegate:self];
        }
        else
        {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            if (indexPath)
            {
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }        
        }
        
    }];
}

- (void)emptyCache
{
    [[EGOCache globalCache] clearCache];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
