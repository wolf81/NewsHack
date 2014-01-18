//
//  FSCommentCell.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSCommentCell.h"


@interface FSCommentCell ()

@property (nonatomic, strong) OHAttributedLabel *commentLabel;

@end


@implementation FSCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        contentView.backgroundColor = FS_COLOR_BACKGROUND;
        contentView.opaque = YES;
    
        self.commentLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
        _commentLabel.font = FS_FONT_SMALL;
        _commentLabel.numberOfLines = 0;
        _commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _commentLabel.opaque = YES;
        _commentLabel.backgroundColor = [UIColor clearColor];
        _commentLabel.automaticallyAddLinksForType = NSTextCheckingTypeLink;
        _commentLabel.linkColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
        [contentView addSubview:_commentLabel];
    }
    return self;
}

- (void)drawContentView:(CGRect)bounds highlighted:(BOOL)highlighted
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat x, y, width, height;
    
    // draw square areas + vertical seperator line ...
    
    for (int i = 0; i <= _commentItem.indentLevel; i++)
    {
        x      = bounds.origin.x + (i * 10);
        y      = bounds.origin.y;
        height = bounds.size.height - y;
        width  = bounds.size.width  - x;
        
        CGFloat c = FS_FLOAT_BACKGROUND_WHITE - (i * 0.02f);
        CGContextSetRGBFillColor(ctx, c, c, c, 1.0f);
        
        CGRect frame = CGRectMake(x + 1, y, width, height);
        CGContextFillRect(ctx, frame);
        
        draw1PxStroke(ctx, CGPointMake(x - 1, y), CGPointMake(x - 1, y + height), FS_COLOR_BAR.CGColor);
        
        width = (i == _commentItem.indentLevel) ? width - x : 10.0f;
    }
    
    
    [[UIColor blackColor] set];
    
    CGSize constraint = CGSizeMake(bounds.size.width, CGFLOAT_MAX);
    CGSize size = [_commentItem.poster sizeWithFont:FS_FONT_SMALL_ITALIC constrainedToSize:constraint lineBreakMode:NSLineBreakByTruncatingTail];
    y = bounds.size.height - size.height - FS_FLOAT_CELL_PADDING_VERTICAL;
    x = bounds.size.width - FS_FLOAT_CELL_PADDING_VERTICAL - size.width;
    
    [_commentItem.poster drawInRect:CGRectMake(x, y, size.width, size.height) withFont:FS_FONT_SMALL_ITALIC lineBreakMode:NSLineBreakByWordWrapping];
    
    
    // draw horizontal seperator line ...
    
    x = bounds.origin.x + 10 * _commentItem.indentLevel;
    CGPoint origin = CGPointMake(x, bounds.origin.y);
    CGPoint point = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y);
    draw1PxStroke(ctx, origin, point, FS_COLOR_BAR.CGColor);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGRect bounds = contentView.frame;
    
    CGFloat x = FS_FLOAT_PADDING + _commentItem.indentLevel * 10.0f;
    CGFloat y = FS_FLOAT_CELL_PADDING_VERTICAL;
    CGFloat width = bounds.size.width - FS_FLOAT_PADDING - x;
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize size = [_commentLabel.attributedText sizeConstrainedToSize:constraint];
    _commentLabel.frame = CGRectMake(x, y, width, size.height);
}

#pragma mark - Public methods

- (void)setCommentItem:(FSCommentItem *)commentItem
{
    if (_commentItem == commentItem)
    {
        return;
    }
        
    _commentItem = commentItem;

    NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:_commentItem.text];
    [string setFont:FS_FONT_SMALL];
    self.commentLabel.attributedText = string ? string : nil;
        
    [self setNeedsDisplay];
}

@end
