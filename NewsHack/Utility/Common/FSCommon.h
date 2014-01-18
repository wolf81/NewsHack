//
//  FSCommon.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/29/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSCommon : NSObject

void drawLinearGradient2(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef midColor, CGColorRef  endColor);
void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor);
void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color);

@end
