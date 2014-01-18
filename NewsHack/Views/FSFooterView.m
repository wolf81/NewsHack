//
//  FSFooterView.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/29/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSFooterView.h"


#define FS_FLOAT_LABEL_DECORATOR_HEIGHT 40.0f


@interface FSFooterView ()

@property (nonatomic, strong) UILabel *decoratorLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@end


@implementation FSFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.opaque           = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor  = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if (_messageLabel.text)
    {
        CGFloat height = [FSFooterView heightWithText:_messageLabel.text withMaximumWidth:rect.size.width];
        CGFloat y = height - FS_FLOAT_LABEL_DECORATOR_HEIGHT;

        CGPoint origin = CGPointMake(0.0f, y);
        CGPoint point  = CGPointMake(rect.origin.x + rect.size.width, y);
        draw1PxStroke(ctx, origin, point, FS_COLOR_BAR.CGColor);
    }
    
    // draw horizontal seperator line ...
    
    CGPoint point = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    draw1PxStroke(ctx, rect.origin, point, FS_COLOR_BAR.CGColor);
}

#pragma mark - Public methods

+ (FSFooterView *)footerViewWithFrame:(CGRect)frame
{
    FSFooterView *view = [[FSFooterView alloc] initWithFrame:frame];
    if (view)
    {
        UILabel *_label              = [[UILabel alloc] initWithFrame:frame];
        _label.autoresizingMask      = UIViewAutoresizingFlexibleWidth;
        _label.textAlignment         = NSTextAlignmentCenter;
        _label.text                  = FS_STRING_FOOTER_VIEW;
        _label.backgroundColor       = [UIColor clearColor];
        _label.opaque                = YES;
        _label.font                  = FS_FONT_MEDIUM;
        _label.textColor             = FS_COLOR_BAR;
        [view addSubview:_label];
        
        view.decoratorLabel = _label;
    }
    return view;
}

+ (FSFooterView *)footerViewWithFrame:(CGRect)frame text:(NSString *)text
{
    FSFooterView *view = [[FSFooterView alloc] initWithFrame:frame];
    if (view)
    {
        UILabel *_messageLabel              = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.autoresizingMask      = UIViewAutoresizingFlexibleWidth;
        _messageLabel.textAlignment         = NSTextAlignmentCenter;
        _messageLabel.numberOfLines         = 0;
        _messageLabel.lineBreakMode         = NSLineBreakByWordWrapping;
        _messageLabel.text                  = text;
        _messageLabel.backgroundColor       = [UIColor clearColor];
        _messageLabel.opaque                = YES;
        _messageLabel.font                  = FS_FONT_SMALL_ITALIC;
        _messageLabel.textColor             = [UIColor blackColor];
        [view addSubview:_messageLabel];

        CGFloat width       = frame.size.width - (FS_FLOAT_PADDING * 2);
        CGFloat y           = FS_FLOAT_PADDING;
        CGSize constraint   = CGSizeMake(width, CGFLOAT_MAX);
        CGSize size         = [text sizeWithFont:FS_FONT_SMALL_ITALIC constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        _messageLabel.frame = CGRectMake(FS_FLOAT_PADDING, FS_FLOAT_PADDING, width, size.height);
        
        view.messageLabel = _messageLabel;
        
        
        y = (FS_FLOAT_PADDING * 2) + size.height;
        CGRect labelFrame = CGRectMake(FS_FLOAT_PADDING, y, width, FS_FLOAT_LABEL_DECORATOR_HEIGHT);

        UILabel *_decoratorLabel              = [[UILabel alloc] initWithFrame:labelFrame];
        _decoratorLabel.autoresizingMask      = UIViewAutoresizingFlexibleWidth;
        _decoratorLabel.textAlignment         = NSTextAlignmentCenter;
        _decoratorLabel.text                  = FS_STRING_FOOTER_VIEW;
        _decoratorLabel.backgroundColor       = [UIColor clearColor];
        _decoratorLabel.opaque                = YES;
        _decoratorLabel.font                  = FS_FONT_MEDIUM;
        _decoratorLabel.textColor             = FS_COLOR_BAR;
        [view addSubview:_decoratorLabel];
        
        view.decoratorLabel = _decoratorLabel;
    }
    return view;
}

+ (CGFloat)heightWithText:(NSString *)text withMaximumWidth:(CGFloat)width
{
    width            -= (FS_FLOAT_PADDING * 2);
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize size       = [text sizeWithFont:FS_FONT_SMALL_ITALIC constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];

    return FS_FLOAT_LABEL_DECORATOR_HEIGHT + size.height + (FS_FLOAT_PADDING * 2);
}

@end
