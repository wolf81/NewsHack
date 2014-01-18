//
//  FSCommentsParser.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSCommentsLoader.h"
#import "AFNetworking.h"
#import "HTMLParser.h"
#import "EGOCache.h"
#import "FSItemList.h"


#define FS_NEWS_ITEM_COMMENTS_DATA_KEY @"FSHackerNewsItemCommentsKey"


@interface FSCommentsLoader ()

- (void)parseCommentsWithData:(NSData *)data
            completionHandler:(void (^)(NSArray *commentItems, NSError *error))completionHandler;

- (void)retrieveFNIDForCommentWithIdentifier:(NSInteger)identifier
                           completionHandler:(void (^)(NSString *FNID, NSError *error))completionHandler;

@end


@implementation FSCommentsLoader

+ (FSCommentsLoader *)sharedLoader
{
    static FSCommentsLoader *loader;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!loader)
        {
            loader = [[FSCommentsLoader alloc] init];
        }
    });
    
    return loader;
}

- (void)cancel
{
    [[NSOperationQueue currentQueue] cancelAllOperations];
}

- (void)retrieveCommentsWithNewsItem:(FSNewsItem *)newsItem
                   completionHandler:(void (^)(FSItemList *itemList, NSError *error))completionHandler
{
    [self retrieveCommentsWithNewsItem:newsItem ignoreCache:NO completionHandler:completionHandler];
}

- (void)retrieveCommentsWithNewsItem:(FSNewsItem *)newsItem
                         ignoreCache:(BOOL)ignoreCache
                   completionHandler:(void (^)(FSItemList *itemList, NSError *error))completionHandler
{
    NSString *key = [FS_NEWS_ITEM_COMMENTS_DATA_KEY stringByAppendingFormat:@"-%d", newsItem.identifier];
    FSItemList *itemList = ignoreCache ? nil : (FSItemList *)[[EGOCache globalCache] objectForKey:key];
    
    if (itemList)
    {
        DLog(@"<<< loading from cache >>>");
        
        if (completionHandler)
        {
            completionHandler(itemList, nil);
        }
        
        return;
    }
    
    
    NSString               *URLString = [NSString stringWithFormat:@"%@/item?id=%d", FS_STRING_BASE_URL, newsItem.identifier];
    NSURL                  *URL       = [NSURL URLWithString:URLString];
    NSURLRequest           *request   = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *data = (NSData *)responseObject;
        
        [self parseCommentsWithData:data completionHandler:^ (NSArray *items, NSError *error) {
            
            if (items)
            {
                FSItemList *itemList = [FSItemList itemListWithItems:items];
                
                DLog(@"<<< storing in cache >>>");
                
                [[EGOCache globalCache] setObject:itemList forKey:key];
                
                if (completionHandler)
                {
                    completionHandler(itemList, nil);
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

- (void)postComment:(NSString *)comment withParentIdentifier:(NSInteger)identifier completionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    [self retrieveFNIDForCommentWithIdentifier:identifier completionHandler:^ (NSString *FNID, NSError *error) {
        
        DLog(@"%@ %@", FNID, error);
        
        if (!FNID)
        {
            if (completionHandler)
            {
                completionHandler(NO, error);
            }
            return;
        }
        
        
        NSURL                  *baseURL    = [NSURL URLWithString:FS_STRING_BASE_URL];
        AFHTTPClient           *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        NSDictionary           *params     = @{@"fnid" : FNID, @"text" : comment};
        NSMutableURLRequest    *request    = [httpClient requestWithMethod:@"POST" path:@"/r" parameters:params];
        AFHTTPRequestOperation *operation  = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        
        // handle redirects - HackerNews will redirect to some page defined in a previous request ...
        
        [AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(300, 3)]];
        [operation setRedirectResponseBlock:^ NSURLRequest* (NSURLConnection *connection, NSURLRequest *request, NSURLResponse *response) {
            
            DLog(@"redirecting to: %@", request.URL);
            
            return request;
            
        }];
        
        
        // load profile data and parse ...
        
        [operation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id responseObject) {
            
            // TODO: figure out to validate if posting went successful ... for now we'll assume it did ...
            
            if (completionHandler)
            {
                completionHandler(YES, nil);
            }
            
        } failure:^ (AFHTTPRequestOperation *operation, NSError *error) {
            
            DLog(@"%@", error);
            
            if (completionHandler)
            {
                completionHandler(NO, error);
            }
            
        }];
        
        [[NSOperationQueue currentQueue] addOperation:operation];
        
    }];
}

- (void)retrieveFNIDForCommentWithIdentifier:(NSInteger)identifier completionHandler:(void (^)(NSString *FNID, NSError *error))completionHandler
{
    // http://news.ycombinator.com/item?id=4975588
    
    NSString               *URLString = [NSString stringWithFormat:@"%@/item?id=%d", FS_STRING_BASE_URL, identifier];
    NSURL                  *URL       = [NSURL URLWithString:URLString];
    NSURLRequest           *request   = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    DLog(@"%@", URLString);
    
    [operation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData  *data  = (NSData *)responseObject;
        NSError *error = nil;
        
        HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
        if (parser)
        {
            HTMLNode *node  = [parser.body findChildWithAttribute:@"name" matchingName:@"fnid" allowPartial:NO];
            NSString *FNID  = [node getAttributeNamed:@"value"];
            NSError  *error = FNID ? nil : [NSError errorWithDomain:FSNewsHackErrorDomain code:FSFNIDParsingFailedError];
            
            if (completionHandler)
            {
                completionHandler(FNID, error);
            }
        }
        else
        {
            if (completionHandler)
            {
                completionHandler(nil, error);
            }
        }
        
    } failure:^ (AFHTTPRequestOperation *operation, NSError *error) {
        
        if (completionHandler)
        {
            completionHandler(nil, error);
        }
        
    }];
    
    [[NSOperationQueue currentQueue] addOperation:operation];
}

#pragma mark - Private methods

- (void)parseCommentsWithData:(NSData *)data
            completionHandler:(void (^)(NSArray *commentItems, NSError *error))completionHandler
{
    NSError    *error  = nil;
    NSString   *html   = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    
    if (parser)
    {
        NSArray *nodes        = [parser.body findChildTags:@"table"];
        HTMLNode *tableNode   = (nodes.count > 3) ? [nodes objectAtIndex:3] : nil;
        NSArray *commentItems = tableNode ? [NSArray array] : nil;
        nodes                 = [tableNode findChildTags:@"table"];
        
        for (HTMLNode *node in nodes)
        {
            FSCommentItem *commentItem = [FSCommentItem commentItemWithNode:node];
            commentItems = [commentItems arrayByAddingObject:commentItem];
        }
        
        if (completionHandler)
        {
            completionHandler(commentItems, nil);
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
