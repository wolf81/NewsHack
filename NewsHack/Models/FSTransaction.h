//
//  FSTransaction.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/31/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSTransaction : NSObject <NSCoding>

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSData   *receipt;

+ (FSTransaction *)transactionWithIdentifier:(NSString *)identifier receipt:(NSData *)receipt;

+ (FSTransaction *)load;
- (void)store;
+ (void)clear;

@end
