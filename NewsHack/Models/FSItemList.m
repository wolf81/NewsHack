//
//  FSNewsItems.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/29/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSItemList.h"


@interface FSItemList ()

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, copy) NSDate  *creationDate;

@end


@implementation FSItemList

- (id)init
{
    self = [super init];
    if (self)
    {
        self.creationDate = [NSDate date];
    }
    return self;
}

+ (FSItemList *)itemListWithItems:(NSArray *)items
{
    FSItemList *item = [[FSItemList alloc] init];
    if (item)
    {
        item.items = items;
    }
    return item;
}

#pragma mark - Encoding / decoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.items        = [aDecoder decodeObjectForKey:@"_items"];
        self.creationDate = [aDecoder decodeObjectForKey:@"_creationDate"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_items        forKey:@"_items"];
    [aCoder encodeObject:_creationDate forKey:@"_creationDate"];

}

@end


