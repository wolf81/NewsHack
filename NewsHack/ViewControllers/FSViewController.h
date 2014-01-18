//
//  FSViewController.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"


@class GADBannerView;

@interface FSViewController : GAITrackedViewController

@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) GADBannerView *bannerView;

- (void)showLoadingIndicator:(BOOL)showIndicator forView:(UIView *)view;
- (void)showLoadingIndicator:(BOOL)showIndicator;
- (void)dismissViewController;

@end
