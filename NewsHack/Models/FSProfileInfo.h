//
//  FSProfileInfo.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/26/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSProfileInfo : NSObject <NSCoding>

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *about;

+ (FSProfileInfo *)profileInfoWithData:(NSData *)data error:(NSError **)error;
- (void)store;
+ (FSProfileInfo *)load;
+ (void)clear;

@end
