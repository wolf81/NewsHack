//
//  FSPostCommentViewController.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/25/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSViewController.h"


@interface FSPostCommentViewController : FSViewController

@property (nonatomic, assign, readonly) NSInteger itemIdentifier;
@property (nonatomic, copy) void (^completionHandler)(BOOL finished);

- (id)initWithItemIdentifier:(NSInteger)identifier;

@end
