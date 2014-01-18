//
//  FSNewsItem.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLParser.h"


@interface FSNewsItem : NSObject <NSCoding>

@property (nonatomic, assign, readonly) BOOL      commentsEnabled;
@property (nonatomic, assign, readonly) NSInteger identifier;
@property (nonatomic, copy, readonly)   NSString *title;
@property (nonatomic, copy, readonly) 	NSURL    *URL;
@property (nonatomic, copy, readonly)   NSString *comments;
@property (nonatomic, copy, readonly)   NSString *time;
@property (nonatomic, copy, readonly)   NSString *points;
@property (nonatomic, copy, readonly) 	NSString *author;

+ (FSNewsItem *)newsItemWithTitleNode:(HTMLNode *)node subTextNode:(HTMLNode *)subNode;

@end
