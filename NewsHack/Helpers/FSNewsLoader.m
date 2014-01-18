//
//  FSNewsParser.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSNewsLoader.h"
#import "AFNetworking.h"
#import "HTMLParser.h"
#import "FSItemList.h"
#import "EGOCache.h"


#define FS_NEWS_ITEMS_DATA_KEY @"FSHackerNewsItemsKey"


@interface FSNewsLoader ()

- (void)parseNewsWithData:(NSData *)data
        completionHandler:(void (^)(NSArray *newsItems, NSError *error))completionHandler;

@end


@implementation FSNewsLoader

+ (FSNewsLoader *)sharedLoader
{
    static FSNewsLoader *loader;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!loader)
        {
            loader = [[FSNewsLoader alloc] init];
        }
    });
    
    return loader;
}

- (void)cancel
{
    [[NSOperationQueue currentQueue] cancelAllOperations];
}

- (void)retrieveNewsIgnoringCache:(BOOL)ignoreCache
            withCompletionHandler:(void (^)(FSItemList *itemList, NSError *error))completionHandler
{
    FSItemList *itemsList = ignoreCache ? nil : (FSItemList *)[[EGOCache globalCache] objectForKey:FS_NEWS_ITEMS_DATA_KEY];
    
    if (itemsList)
    {
        DLog(@"<<< loading from cache >>>");
        
        if (completionHandler)
        {
            completionHandler(itemsList, nil);
        }
        
        return;
    }
    
    
    NSURL                  *URL       = [NSURL URLWithString:FS_STRING_BASE_URL];
    NSURLRequest           *request   = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *data = (NSData *)responseObject;
        
        [self parseNewsWithData:data completionHandler:^ (NSArray *items, NSError *error) {
            
            if (items)
            {
                FSItemList *itemsList = [FSItemList itemListWithItems:items];
                
                DLog(@"<<< storing in cache >>>");
                
                [[EGOCache globalCache] setObject:itemsList forKey:FS_NEWS_ITEMS_DATA_KEY];
                
                if (completionHandler)
                {
                    completionHandler(itemsList, nil);
                }
            }
            else
            {
                if (completionHandler)
                {
                    completionHandler(nil, error);
                }
            }
            
        }];
        
    } failure:^ (AFHTTPRequestOperation *operation, NSError *error) {
        
        if (completionHandler)
        {
            completionHandler(nil, error);
        }
        
    }];
    
    [[NSOperationQueue currentQueue] addOperation:operation];
}

- (void)parseNewsWithData:(NSData *)data completionHandler:(void (^)(NSArray *newsItems, NSError *error))completionHandler
{
    NSError    *error  = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
    
    if (parser)
    {
        NSArray    *nodes  = [parser.body findChildTags:@"table"];
        HTMLNode   *table  = (nodes.count == 4) ? [nodes objectAtIndex:2] : nil;
        nodes              = [table findChildTags:@"tr"];
        
        if (nodes)
        {
            NSArray *newsItems = [NSArray array];
            for (int i = 0; i < nodes.count; i+= 3)
            {
                HTMLNode *titleNode = [nodes objectAtIndex:i];
                HTMLNode *subTextNode = [nodes objectAtIndex:(i + 1)];
                
                FSNewsItem *newsItem = [FSNewsItem newsItemWithTitleNode:titleNode subTextNode:subTextNode];
                if (newsItem.title)
                {
                    newsItems = [newsItems arrayByAddingObject:newsItem];
                }
            }
            
            if (completionHandler)
            {
                completionHandler(newsItems, nil);
            }
        }
        else // if we did not get a nodes object, table structure must have changed ...
        {
            if (completionHandler)
            {
                completionHandler(nil, error);
            }
        }
    }
    else
    {
        if (completionHandler)
        {
            completionHandler(nil, error);
        }
    }
}

@end
