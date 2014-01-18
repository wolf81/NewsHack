//
//  FSProfileViewCell.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/27/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSProfileViewCell.h"


@interface FSProfileViewCell ()


@end


@implementation FSProfileViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        contentView.backgroundColor = [UIColor clearColor];
        contentView.opaque = YES;
        self.backgroundColor = [UIColor clearColor];
        
        self.titleLabel                      = [[UILabel alloc] init];
        self.titleLabel.font                 = FS_FONT_MEDIUM;
        self.titleLabel.backgroundColor      = [UIColor clearColor];
        self.titleLabel.opaque               = YES;
        self.titleLabel.highlightedTextColor = [UIColor whiteColor];
        self.titleLabel.textAlignment        = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines        = 1;
        self.titleLabel.lineBreakMode        = NSLineBreakByTruncatingTail;
        
        [self addSubview:_titleLabel];
        
        selectedContentView.backgroundColor = FS_COLOR_CELL_SELECTED;
        
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        selectedBackgroundView.backgroundColor = FS_COLOR_CELL_SELECTED;
        self.selectedBackgroundView = selectedBackgroundView;
    }
    return self;
}

- (void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    CGFloat c = FS_FLOAT_BACKGROUND_WHITE;
    CGContextSetRGBFillColor(ctx, c, c, c, 1.0f);
    CGContextFillRect(ctx, rect);
    
    
    CGPoint point = CGPointMake(rect.size.width, rect.origin.y);
    draw1PxStroke(ctx, rect.origin, point, highlighted ? FS_COLOR_CELL_SELECTED.CGColor : FS_COLOR_BAR.CGColor);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGRect bounds = contentView.bounds;
    
    CGFloat width = bounds.size.width - (FS_FLOAT_PADDING * 2);
    CGFloat height = _titleLabel.font.lineHeight;
    CGFloat y = (int)(bounds.size.height - height) / 2;
    _titleLabel.frame = CGRectMake(FS_FLOAT_PADDING, y, width, height);
}

#pragma mark -

- (void)setTitle:(NSString *)title
{
    if ([_title isEqualToString:title])
    {
        return;
    }
    
    _title = title;
    
    _titleLabel.text = title;
    
    [self setNeedsLayout];
}

@end
