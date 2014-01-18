//
//  FSNewsCell.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSNewsItem.h"
#import "ABTableViewCell.h"


@interface FSNewsCell : ABTableViewCell

@property (nonatomic, strong) FSNewsItem *newsItem;

@end
