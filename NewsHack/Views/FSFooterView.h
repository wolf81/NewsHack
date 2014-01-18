//
//  FSFooterView.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/29/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FSFooterView : UIView

+ (FSFooterView *)footerViewWithFrame:(CGRect)frame;
+ (FSFooterView *)footerViewWithFrame:(CGRect)frame text:(NSString *)text;
+ (CGFloat)heightWithText:(NSString *)text withMaximumWidth:(CGFloat)width;

@end
