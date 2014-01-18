//
//  FSNewsItemViewController.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSViewController.h"
#import "FSNewsItem.h"


@interface FSNewsItemViewController : FSViewController

@property (nonatomic, strong, readonly) FSNewsItem *newsItem;

+ (FSNewsItemViewController *)newsItemViewControllerWithNewsItem:(FSNewsItem *)newsItem;

@end
