//
//  FSMarqueeView.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/24/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSMarqueeView.h"
#import "MarqueeLabel.h"


@interface FSMarqueeView ()

@property (nonatomic, strong) MarqueeLabel *label;

@end


@implementation FSMarqueeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {   
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.label = [[MarqueeLabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor  = [UIColor clearColor];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _label.opaque           = YES;
        _label.font             = FS_FONT_MEDIUM;
        _label.textColor        = [UIColor whiteColor];
        _label.textAlignment    = NSTextAlignmentCenter;
        _label.marqueeType      = MLContinuous;
        _label.continuousMarqueeSeparator = @"   |   ";
        [self addSubview:_label];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    // draw horizontal seperator line ...

    UIColor *endColor   = [UIColor colorWithRed:1.0f green:0.6f blue:0.1f alpha:1.0f];
    UIColor *midColor   = FS_COLOR_BAR;
    UIColor *startColor = [UIColor colorWithRed:0.9f green:0.5f blue:0.1f alpha:1.0f];
    drawLinearGradient2(ctx, rect, startColor.CGColor, midColor.CGColor, endColor.CGColor);
}

- (void)dealloc
{
    self.label = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    CGRect labelFrame       = self.bounds;
    labelFrame.size.height -= 2;
    labelFrame.origin.y    += 1;
    self.label.frame        = labelFrame;
    
    _label.textAlignment = NSTextAlignmentCenter;
}

- (void)setText:(NSString *)text
{
    if ([_text isEqualToString:text])
    {
        return;
    }
    
    _text = text;
    _label.text = text;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)pauseAnimation
{
    [_label pauseLabel];
}

- (void)continueAnimation
{
    [_label unpauseLabel];
}

- (void)setLabelize:(BOOL)labelize
{
    _label.labelize = YES;
}


@end
