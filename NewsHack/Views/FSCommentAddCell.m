//
//  FSCommentAddCell.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/25/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSCommentAddCell.h"


@interface FSCommentAddCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation FSCommentAddCell

@synthesize imageView = imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.opaque = YES;
        self.backgroundColor = FS_COLOR_BACKGROUND;
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.backgroundColor = FS_COLOR_CELL_SELECTED;
        self.selectedBackgroundView = backgroundView;

        
        UIImage *image1 = FS_IMAGE_CHAT_DARK;
        UIImage *image2 = FS_IMAGE_CHAT_LIGHT;
        self.imageView = [[UIImageView alloc] initWithImage:image1 highlightedImage:image2];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];   
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
    
    CGPoint point = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    draw1PxStroke(ctx, rect.origin, point, highlighted ? FS_COLOR_CELL_SELECTED.CGColor : FS_COLOR_BAR.CGColor);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGRect bounds = self.bounds;
    CGFloat length = 30.0f;
    CGFloat x = (bounds.size.width - length) / 2;
    CGFloat y = (bounds.size.height - length) / 2 + 1;
    self.imageView.frame = CGRectMake(x, y, length, length);
}

@end
