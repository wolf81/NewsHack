//
//  FSWebViewController.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSViewController.h"
#import "FSNewsItem.h"


@interface FSWebViewController : FSViewController

+ (FSWebViewController *)webViewControllerWithURL:(NSURL *)URL;

@property (nonatomic, strong, readonly) FSNewsItem *newsItem;

@end
