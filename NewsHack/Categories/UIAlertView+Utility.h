//
//  UIAlertView+Utility.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/29/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIAlertView (Utility)

+ (void)showAlertViewWithError:(NSError *)error delegate:(id <UIAlertViewDelegate>)delegate;

@end
