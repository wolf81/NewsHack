//
//  FSMarqueeView.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/24/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FSMarqueeView : UIView

@property (nonatomic, copy) NSString *text;

- (void)pauseAnimation;
- (void)continueAnimation;
- (void)setLabelize:(BOOL)labelize;

@end
