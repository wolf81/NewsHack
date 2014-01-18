//
//  UIAlertView+Utility.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/29/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "UIAlertView+Utility.h"


@implementation UIAlertView (Utility)

+ (void)showAlertViewWithError:(NSError *)error delegate:(id <UIAlertViewDelegate>)delegate
{
    NSString    *title      = NSLocalizedString(@"Error", nil);
    NSString    *buttonText = NSLocalizedString(@"OK", nil);
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:title message:error.localizedDescription delegate:delegate cancelButtonTitle:buttonText otherButtonTitles:nil];
    
    [alertView show];
}

@end
