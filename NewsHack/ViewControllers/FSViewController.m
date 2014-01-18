//
//  FSViewController.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSViewController.h"
#import "DejalActivityView.h"
#import "FSTableView.h"
#import "GADBannerView.h"
#import <AdSupport/AdSupport.h>
#import "FSTransaction.h"


#define FS_FLOAT_BANNER_HEIGHT_PORTRAIT  50.0f
#define FS_FLOAT_BANNER_HEIGHT_LANDSCAPE 32.0f



@interface FSViewController ()

- (void)hideBannerView;

@end


@implementation FSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    const CGRect bounds = self.view.bounds;
    CGRect frame        = CGRectZero;
    
    CGFloat bannerHeight = 0.0f;
    
    BOOL showBanner = ([FSTransaction load] == nil);
    if (showBanner)
    {
        bannerHeight = ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
                        [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight ?
                        FS_FLOAT_BANNER_HEIGHT_LANDSCAPE : FS_FLOAT_BANNER_HEIGHT_PORTRAIT);
    }
    
    
    frame = CGRectMake(0.0f, 0.0f, bounds.size.width, bounds.size.height - bannerHeight);
    self.contentView = [[UIView alloc] initWithFrame:frame];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_contentView];
    
    
    CGPoint origin = CGPointMake(0.0f, bounds.size.height - bannerHeight);
    frame = CGRectMake(0.0f, bounds.size.height - bannerHeight, bounds.size.width, bannerHeight);
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait origin:origin];
    _bannerView.adUnitID = @"a150dfd53f558cd";
    _bannerView.rootViewController = self;
    _bannerView.backgroundColor = [UIColor colorWithWhite:0.1f alpha:1.0f];
    _bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_bannerView];
    
    if (showBanner)
    {
        GADRequest *request = [GADRequest request];
        
#if (DEBUG || RELEASE)
        NSString *uniqueIdentifier = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        request.testDevices = @[uniqueIdentifier];
#endif
        
        [_bannerView loadRequest:[GADRequest request]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBannerView) name:FSShouldDisableAdsNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    const CGRect bounds = self.view.bounds;
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        _contentView.frame = CGRectMake(0.0f, 0.0f, bounds.size.width, bounds.size.height - FS_FLOAT_BANNER_HEIGHT_LANDSCAPE);
        _bannerView.frame  = CGRectMake(0.0f, bounds.size.height - FS_FLOAT_BANNER_HEIGHT_LANDSCAPE, bounds.size.width, FS_FLOAT_BANNER_HEIGHT_LANDSCAPE);
        
        [_bannerView setAdSize:kGADAdSizeSmartBannerLandscape];
    }
    else
    {
        _contentView.frame = CGRectMake(0.0f, 0.0f, bounds.size.width, bounds.size.height - FS_FLOAT_BANNER_HEIGHT_PORTRAIT);
        _bannerView.frame  = CGRectMake(0.0f, bounds.size.height - FS_FLOAT_BANNER_HEIGHT_PORTRAIT, bounds.size.width, FS_FLOAT_BANNER_HEIGHT_PORTRAIT);
        
        [_bannerView setAdSize:kGADAdSizeSmartBannerPortrait];
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    self.trackedViewName = title;
}

#pragma mark - Public methods

- (void)showLoadingIndicator:(BOOL)showIndicator forView:(UIView *)view
{
    if ([view isKindOfClass:[FSTableView class]])
    {
        FSTableView *tableView = (FSTableView *)view;
        
        if (tableView.isRefreshing)
        {
            return;
        }
    }
    
    if (showIndicator)
    {
        view.userInteractionEnabled = NO;
        DejalActivityView *activityView = [DejalBezelActivityView activityViewForView:view];
        activityView.showNetworkActivityIndicator = YES;
        [activityView animateShow];
    }
    else
    {
        view.userInteractionEnabled = YES;
        [[DejalActivityView currentActivityView] animateRemove];
    }
}

- (void)showLoadingIndicator:(BOOL)showIndicator
{
    [self showLoadingIndicator:showIndicator forView:self.contentView];
}

- (void)dismissViewController
{
    [self showLoadingIndicator:NO];
    
    if (self.navigationController)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private methods

- (void)hideBannerView
{
    if ([self.navigationController visibleViewController] == self)
    {
        _bannerView.alpha = 1.0f;
        [UIView animateWithDuration:0.3f animations:^ {
            _bannerView.alpha = 0.0f;
            _contentView.frame = self.view.bounds;
        } completion:^ (BOOL finished) {
            _bannerView.frame = CGRectZero;
        }];
    }
    else
    {
        _bannerView.frame = CGRectZero;
        _contentView.frame = self.view.bounds;
    }    
}


@end
