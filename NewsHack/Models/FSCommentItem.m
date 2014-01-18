//
//  FSCommentItem.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSCommentItem.h"
#import "NSString+HTML.h"


@interface FSCommentItem ()

@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, assign) NSInteger indentLevel;
@property (nonatomic, copy)   NSString *poster;
@property (nonatomic, copy)   NSString *time;
@property (nonatomic, copy)   NSString *text;

@end


@implementation FSCommentItem

+ (FSCommentItem *)commentItemWithNode:(HTMLNode *)commentNode
{
    FSCommentItem *commentItem = [[FSCommentItem alloc] init];
    if (commentItem)
    {
        HTMLNode *node   = nil;
        NSString *string = nil;
                        
        node = [commentNode findChildWithAttribute:@"src" matchingName:@"http://ycombinator.com/images/s.gif" allowPartial:NO];
        string = [node getAttributeNamed:@"width"];
        commentItem.indentLevel = string ? (string.integerValue / 40) : 0;
        
        node = [commentNode findChildWithAttribute:@"class" matchingName:@"comment" allowPartial:NO];        
        commentItem.text = [node.rawContents stringByStrippingHTML];
        
        node = [commentNode findChildWithAttribute:@"href" matchingName:@"user?id=" allowPartial:YES];
        commentItem.poster = node.allContents;
        
        node = [commentNode findChildWithAttribute:@"href" matchingName:@"item?id=" allowPartial:YES];
        string = [node getAttributeNamed:@"href"];
        NSRange range = [string rangeOfString:@"="];
        if (range.location != NSNotFound)
        {
            commentItem.identifier = [string substringFromIndex:(range.location + 1)].integerValue;
        }
    }
    return commentItem;
}

- (NSString *)description
{
    NSString *text = nil;
    
    NSInteger maxLength = 30;
    if (_text.length > maxLength)
    {
        text = [_text substringToIndex:maxLength];
        text = [text stringByAppendingFormat:@"..."];
    }
    else
    {
        text = _text;
    }
    
    return [text stringByAppendingFormat:@" - %@", _poster];
}

#pragma mark - Encoding / decoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.identifier  = [aDecoder decodeIntegerForKey:@"_identifier"];
        self.indentLevel = [aDecoder decodeIntegerForKey:@"_indentLevel"];
        self.poster      = [aDecoder decodeObjectForKey:@"_poster"];
        self.time        = [aDecoder decodeObjectForKey:@"_time"];
        self.text        = [aDecoder decodeObjectForKey:@"_text"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_identifier  forKey:@"_identifier"];
    [aCoder encodeInteger:_indentLevel forKey:@"_indentLevel"];
    [aCoder encodeObject: _poster      forKey:@"_poster"];
    [aCoder encodeObject: _time        forKey:@"_time"];
    [aCoder encodeObject: _text        forKey:@"_text"];
}

@end
