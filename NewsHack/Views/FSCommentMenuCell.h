//
//  FSEditMenuCell.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/25/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "ABTableViewCell.h"


@protocol FSCommentMenuCellDelegate;

@interface FSCommentMenuCell : ABTableViewCell

@property (nonatomic, assign) id <FSCommentMenuCellDelegate> delegate;
@property (nonatomic, assign) NSInteger indentLevel;

@end


@protocol FSCommentMenuCellDelegate <NSObject>

- (void)cellCommentButtonTouched:(FSCommentMenuCell *)cell;

@end