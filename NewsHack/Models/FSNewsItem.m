//
//  FSNewsItem.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSNewsItem.h"


@interface FSNewsItem ()

@property (nonatomic, assign) BOOL      commentsEnabled;
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSURL    *URL;
@property (nonatomic, copy)   NSString *comments;
@property (nonatomic, copy)   NSString *time;
@property (nonatomic, copy)   NSString *points;
@property (nonatomic, copy)   NSString *author;

@end


@implementation FSNewsItem

+ (FSNewsItem *)newsItemWithTitleNode:(HTMLNode *)titleNode subTextNode:(HTMLNode *)subTextNode
{
    FSNewsItem *newsItem = [[FSNewsItem alloc] init];
    if (newsItem)
    {
        HTMLNode *node         = nil;
        NSString *searchString = nil;
        
        
        // parse title node ...

        searchString = @"up_";
        node = [titleNode findChildWithAttribute:@"id" matchingName:searchString allowPartial:YES];
        if (node)
        {
            NSString *string = [node getAttributeNamed:@"id"];
            string = [string substringFromIndex:searchString.length];
            newsItem.identifier = string.integerValue;
        }
        
        NSArray  *nodes       = [titleNode findChildrenWithAttribute:@"class" matchingName:@"title" allowPartial:YES];
        node                  = (nodes.count == 2) ? [nodes objectAtIndex:1] : nil;
        NSString *titleString = node ? node.allContents : nil;
        newsItem.title        = [titleString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        node                  = [node findChildTag:@"a"];
        NSString *URLString   = [node getAttributeNamed:@"href"];
        URLString = [URLString stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        newsItem.URL          = [URLString hasPrefix:@"http"] ? [NSURL URLWithString:URLString] : nil;
        
        
        // parse subText node ...
                
        node = [subTextNode findChildWithAttribute:@"id" matchingName:@"score" allowPartial:YES];
        newsItem.points = node.allContents;
        
        node = [subTextNode findChildWithAttribute:@"href" matchingName:@"user" allowPartial:YES];
        newsItem.author = node.allContents;
        
        node = [subTextNode findChildWithAttribute:@"href" matchingName:@"item" allowPartial:YES];
        newsItem.comments = node.allContents;
        
        searchString = [NSString stringWithFormat:@"%@</a>", newsItem.author];
        NSRange range = [subTextNode.rawContents rangeOfString:searchString];
        if (range.location != NSNotFound)
        {
            NSString *timeString = [subTextNode.rawContents substringFromIndex:range.location + range.length];
            range = [timeString rangeOfString:@"|"];
            if (range.location != NSNotFound)
            {
                timeString = [timeString substringToIndex:range.location];
                timeString = [timeString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                newsItem.time = timeString;
            }
            
            newsItem.commentsEnabled = (newsItem.comments != nil);
        }
        else
        {
            newsItem.commentsEnabled = (newsItem.comments != nil);
            newsItem.time = subTextNode.allContents;
        }
    }
    return newsItem;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", self.title, self.URL];
}

#pragma mark - Encoding / decoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.commentsEnabled = [aDecoder decodeBoolForKey:@"_commentsEnabled"];
        self.identifier      = [aDecoder decodeIntegerForKey:@"_identifier"];
        self.title           = [aDecoder decodeObjectForKey:@"_title"];
        self.URL             = [aDecoder decodeObjectForKey:@"_URL"];
        self.comments        = [aDecoder decodeObjectForKey:@"_comments"];
        self.time            = [aDecoder decodeObjectForKey:@"_time"];
        self.points          = [aDecoder decodeObjectForKey:@"_points"];
        self.author          = [aDecoder decodeObjectForKey:@"_author"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_commentsEnabled forKey:@"_commentsEnabled"];
    [aCoder encodeInteger:_identifier   forKey:@"_identifier"];
    [aCoder encodeObject:_title         forKey:@"_title"];
    [aCoder encodeObject:_URL           forKey:@"_URL"];
    [aCoder encodeObject:_comments      forKey:@"_comments"];
    [aCoder encodeObject:_time          forKey:@"_time"];
    [aCoder encodeObject:_points        forKey:@"_points"];
    [aCoder encodeObject:_author        forKey:@"_author"];
}

@end
