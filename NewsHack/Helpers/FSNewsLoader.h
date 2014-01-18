//
//  FSNewsParser.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSItemList.h"
#import "FSNewsItem.h"


@interface FSNewsLoader : NSObject

- (void)retrieveNewsIgnoringCache:(BOOL)ignoreCache
            withCompletionHandler:(void (^)(FSItemList *newsItems, NSError *error))completionHandler;

+ (FSNewsLoader *)sharedLoader;
- (void)cancel;

@end
