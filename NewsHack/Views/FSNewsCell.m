//
//  FSNewsCell.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSNewsCell.h"


@interface FSNewsCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end


@implementation FSNewsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.titleLabel                       = [[UILabel alloc] init];
        self.titleLabel.font                  = FS_FONT_MEDIUM;
        self.titleLabel.backgroundColor       = [UIColor clearColor];
        self.titleLabel.opaque                = YES;
        self.titleLabel.highlightedTextColor  = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        
        self.detailLabel                      = [[UILabel alloc] init];
        self.detailLabel.font                 = FS_FONT_SMALL;
        self.detailLabel.backgroundColor      = [UIColor clearColor];
        self.detailLabel.opaque               = YES;
        self.detailLabel.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:_detailLabel];

        self.backgroundColor = [UIColor clearColor];
        
        UIView *selectedBackgroundView         = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = FS_COLOR_CELL_SELECTED;
        self.selectedBackgroundView            = selectedBackgroundView;        
    }
    return self;
}

- (void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    
    // draw background ...
    
    CGFloat c = FS_FLOAT_BACKGROUND_WHITE;
    CGContextSetRGBFillColor(ctx, c, c, c, 1.0f);
    CGContextFillRect(ctx, rect);
    
    
    // draw horizontal seperator line ...
    const CGRect bounds = rect;
    CGFloat x = 0.0f;
    CGPoint origin = CGPointMake(x, bounds.origin.y);
    CGPoint point = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y);
    draw1PxStroke(ctx, origin, point, highlighted ? FS_COLOR_CELL_SELECTED.CGColor : FS_COLOR_BAR.CGColor);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    const CGRect bounds = self.bounds;
    CGFloat width = bounds.size.width - (FS_FLOAT_PADDING * 2) - 15.0f;
    _titleLabel.frame = CGRectMake(FS_FLOAT_PADDING, FS_FLOAT_CELL_PADDING_VERTICAL, width, 20.0f);
    
    CGFloat y = _titleLabel.frame.size.height + (FS_FLOAT_CELL_PADDING_VERTICAL * 2);
    _detailLabel.frame = CGRectMake(FS_FLOAT_PADDING, y, width, 15.0f);
}

#pragma mark - Private

- (void)setNewsItem:(FSNewsItem *)newsItem
{
    if (_newsItem == newsItem)
    {
        return;
    }
    
    _newsItem = newsItem;
        
    self.titleLabel.text = newsItem.title;
    
    if (_newsItem.points && _newsItem.time)
    {
        self.detailLabel.text = [NSString stringWithFormat:@"%@ | %@", _newsItem.points, newsItem.time];
    }
    else
    {
        self.detailLabel.text = newsItem.time;
    }
    
    [self setNeedsLayout];
}

@end
