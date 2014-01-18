//
//  NSError+Utility.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/29/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSError (Utility)

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code;

@end
