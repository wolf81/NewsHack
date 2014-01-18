//
//  FSCell.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/25/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSCell.h"

@implementation FSCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.textLabel.font       = FS_FONT_MEDIUM;
        self.detailTextLabel.font = FS_FONT_SMALL;
        self.backgroundColor = [UIColor clearColor];
        
        UIView  *backgroundView        = [[UIView alloc] init];
        backgroundView.backgroundColor = FS_COLOR_CELL_SELECTED;
        self.selectedBackgroundView    = backgroundView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
