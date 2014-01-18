//
//  FSAppDelegate.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSAppDelegate.h"
#import "FSMasterViewController.h"
#import "FSDetailViewController.h"
#import "FSProductStore.h"
#import "EGOCache.h"
#import "GAI.h"


@interface FSAppDelegate ()

@property (nonatomic, assign) id <GAITracker> tracker;

- (void)setupRootControlleriPhone;
- (void)setupRootControlleriPad;
- (void)setupAnalytics;

@end


@implementation FSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self setupRootControlleriPhone];
    }
    else
    {
        [self setupRootControlleriPad];
    }
    
    [[EGOCache globalCache] setDefaultTimeoutInterval:FS_INTERVAL_CACHE_TIMEOUT];
    
    [[UINavigationBar appearance] setTintColor:FS_COLOR_BAR];
    UIOffset offset = UIOffsetMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont : FS_FONT_BIG, UITextAttributeTextShadowColor : [UIColor darkGrayColor], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:offset]}];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    [[FSProductStore defaultStore] registerObserver];
    
    [self setupAnalytics];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    [[GAI sharedInstance] dispatch];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private

- (void)setupAnalytics
{
    // Optional: automatically track uncaught exceptions with Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = -1;
    // Optional: set debug to YES for extra debugging information.
    
#ifdef DEBUG
    [GAI sharedInstance].debug = YES;
#else
    [GAI sharedInstance].debug = NO;
#endif
    
    // Create tracker instance.
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:FS_ANALYTICS_TRACKING_ID];
}

- (void)setupRootControlleriPhone
{
    FSMasterViewController *masterViewController = [[FSMasterViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    self.window.rootViewController = self.navigationController;
}

- (void)setupRootControlleriPad
{
    FSMasterViewController *masterViewController = [[FSMasterViewController alloc] initWithNibName:@"FSMasterViewController_iPad" bundle:nil];
    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    
    FSDetailViewController *detailViewController = [[FSDetailViewController alloc] initWithNibName:@"FSDetailViewController_iPad" bundle:nil];
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    masterViewController.detailViewController = detailViewController;
    
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = detailViewController;
    self.splitViewController.viewControllers = @[masterNavigationController, detailNavigationController];
    
    
    self.window.rootViewController = self.splitViewController;
}

#pragma mark - Public methods

+ (void)navigateToUserViewController
{
    FSAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.navigationController popToRootViewControllerAnimated:YES];
    
    int64_t delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        FSMasterViewController *rootViewController = [appDelegate.navigationController.viewControllers objectAtIndex:0];
        [rootViewController pushToUserViewController];
    });
    
}

@end
