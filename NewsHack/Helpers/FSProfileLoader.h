//
//  FSProfileLoader.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/26/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSProfileInfo.h"


@interface FSProfileLoader : NSObject

+ (FSProfileLoader *)sharedLoader;

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
        completionHandler:(void (^)(FSProfileInfo *profileInfo, NSError *error))completionHandler;

- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
           completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

- (void)logoutWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

- (void)cancel;

@end
