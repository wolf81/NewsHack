//
//  FSEditMenuCell.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/25/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSCommentMenuCell.h"


@interface FSCommentMenuCell ()

@property (nonatomic, strong) UIButton *voteUpButton;
@property (nonatomic, strong) UIButton *voteDownButton;
@property (nonatomic, strong) UIButton *commentButton;

- (void)commentButtonTouched:(id)sender;

@end

@implementation FSCommentMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        contentView.backgroundColor = FS_COLOR_BACKGROUND;
        contentView.opaque = YES;

        UIImage *image1 = FS_IMAGE_CHAT_DARK;
        UIImage *image2 = FS_IMAGE_CHAT_LIGHT;
        
        self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentButton setImage:image1 forState:UIControlStateNormal];
        [_commentButton setImage:image2 forState:UIControlStateHighlighted];
        [_commentButton addTarget:self action:@selector(commentButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_commentButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    const CGRect bounds = self.bounds;

    CGFloat length = bounds.size.height - (FS_FLOAT_CELL_PADDING_VERTICAL * 2);
    CGFloat x = bounds.size.width - FS_FLOAT_CELL_PADDING_VERTICAL - length;
    _commentButton.frame = CGRectMake(x, FS_FLOAT_CELL_PADDING_VERTICAL, length, length);
}

- (void)drawContentView:(CGRect)bounds highlighted:(BOOL)highlighted
{
    UIColor *lineColor = FS_COLOR_BAR;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    // draw square areas + vertical seperator line ...
    
    for (int i = 0; i <= _indentLevel; i++)
    {
        CGFloat x = bounds.origin.x + (i * 10);
        CGFloat y = bounds.origin.y;
        CGFloat height = bounds.size.height - y;
        CGFloat width  = bounds.size.width  - x;
        
        CGFloat c = FS_FLOAT_BACKGROUND_WHITE - (i * 0.023f);
        CGContextSetRGBFillColor(ctx, c, c, c, 1.0f);
        
        CGRect frame = CGRectMake(x + 1, y, width, height);
        CGContextFillRect(ctx, frame);
        
        draw1PxStroke(ctx, CGPointMake(x - 1, y), CGPointMake(x - 1, y + height), lineColor.CGColor);
        
        width = (i == _indentLevel) ? width - x : 10.0f;
        
    }
    
    
    static CGFloat const kDashedPhase           = (0.0f);
    static CGFloat const kDashedLinesLength[]   = {2.0f, 2.0f};
    static size_t const kDashedCount            = (2.0f);
    CGContextSetLineDash(ctx, kDashedPhase, kDashedLinesLength, kDashedCount) ;
    

     // draw horizontal seperator line ...
     
     CGFloat x = bounds.origin.x + 10 * _indentLevel;
     CGPoint origin = CGPointMake(x + 1, bounds.origin.y);
     CGPoint point = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y);
     draw1PxStroke(ctx, origin, point, [UIColor lightGrayColor].CGColor);

}

#pragma mark - Private methods

- (void)commentButtonTouched:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellCommentButtonTouched:)])
    {
        [self.delegate cellCommentButtonTouched:self];
    }
}

- (void)setIndentLevel:(NSInteger)indentLevel
{
    if (_indentLevel == indentLevel)
    {
        return;
    }
    
    _indentLevel = indentLevel;
    
    [self setNeedsDisplay];
}

@end
