//
//  FSCommentsParser.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSNewsItem.h"
#import "FSCommentItem.h"
#import "FSItemList.h"


@interface FSCommentsLoader : NSObject

- (void)retrieveCommentsWithNewsItem:(FSNewsItem *)newsItem
                   completionHandler:(void (^)(FSItemList *itemList, NSError *error))completionHandler;

- (void)retrieveCommentsWithNewsItem:(FSNewsItem *)newsItem
                         ignoreCache:(BOOL)ignoreCache
                   completionHandler:(void (^)(FSItemList *itemList, NSError *error))completionHandler;


- (void)postComment:(NSString *)comment
withParentIdentifier:(NSInteger)integer
  completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

- (void)cancel;

+ (FSCommentsLoader *)sharedLoader;

@end
