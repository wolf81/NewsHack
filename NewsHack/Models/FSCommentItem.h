//
//  FSCommentItem.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNode.h"


@interface FSCommentItem : NSObject <NSCoding>

@property (nonatomic, assign, readonly) NSInteger identifier;
@property (nonatomic, assign, readonly) NSInteger indentLevel;
@property (nonatomic, copy, readonly)   NSString *poster;
@property (nonatomic, copy, readonly)   NSString *time;
@property (nonatomic, copy, readonly)   NSString *text;

+ (FSCommentItem *)commentItemWithNode:(HTMLNode *)node;

@end
