//
//  FSNewsItems.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/29/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>


// the only use for this 'wrapper' is to prevent the need to duplicate the
//  itemCreationDate variable to every object included in the items array
//  the itemCreationDate is used for caching purposes ...

@interface FSItemList : NSObject <NSCoding>

+ (FSItemList *)itemListWithItems:(NSArray *)items;

@property (nonatomic, copy, readonly) NSDate  *creationDate;
@property (nonatomic, copy, readonly) NSArray *items;

@end
