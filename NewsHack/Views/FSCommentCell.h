//
//  FSCommentCell.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCommentItem.h"
#import "OHAttributedLabel.h"
#import "ABTableViewCell.h"


@interface FSCommentCell : ABTableViewCell

@property (nonatomic, strong, readonly) OHAttributedLabel *commentLabel;
@property (nonatomic, strong)           FSCommentItem     *commentItem;

@end

