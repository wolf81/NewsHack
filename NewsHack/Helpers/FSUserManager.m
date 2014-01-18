//
//  FSUserManager.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/27/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSUserManager.h"


@implementation FSUserManager

+ (FSUserManager *)sharedManager
{
    static FSUserManager *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager)
        {
            manager = [[FSUserManager alloc] init];
        }
    });
    
    return manager;
}

- (FSProfileInfo *)currentProfile
{
    return [FSProfileInfo load];
}

@end
