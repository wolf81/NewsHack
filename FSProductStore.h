//
//  FSAppStore.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/30/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>


#define FS_PRODUCT_DISABLE_ADS @"newshack01"


@interface FSProductStore : NSObject

+ (FSProductStore *)defaultStore;

// AppDelegate will call this on app start ...
- (void)registerObserver;

// handling product requests ...
- (void)startProductRequestWithIdentifier:(NSString *)productIdentifier
                        completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;
- (void)cancelProductRequest;

@end
