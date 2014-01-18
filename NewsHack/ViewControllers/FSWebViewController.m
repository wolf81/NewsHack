//
//  FSWebViewController.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSWebViewController.h"


@interface FSWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView  *webView;
@property (nonatomic, copy)   NSURL      *URL;

- (void)loadData;
- (void)openURLInSafari;

@end


@implementation FSWebViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.title = @"Webpage";
    }
    return self;
}

+ (FSWebViewController *)webViewControllerWithURL:(NSURL *)URL
{
    FSWebViewController *viewController = [[FSWebViewController alloc] init];
    if (viewController)
    {
        viewController.URL = URL;
    }
    return viewController;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_webView stopLoading];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.webView = [[UIWebView alloc] initWithFrame:self.contentView.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.backgroundColor  = FS_COLOR_BACKGROUND;
    _webView.delegate         = self;
    _webView.scalesPageToFit  = YES;
    [self.view addSubview:_webView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openURLInSafari)];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Web view delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self showLoadingIndicator:NO];    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self showLoadingIndicator:NO];
    
    if (error.code != NSURLErrorCancelled)
    {
        [self.webView loadHTMLString:error.localizedDescription baseURL:nil];
    }
}

#pragma mark - Private methods

- (void)loadData
{
    if (_URL)
    {
        [self showLoadingIndicator:YES];

        NSURLRequest *request = [NSURLRequest requestWithURL:_URL];
        [_webView loadRequest:request];
    }
    else
    {
        DLog(@"WARNING: no URL in news item");
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
