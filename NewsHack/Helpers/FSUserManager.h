//
//  FSUserManager.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/27/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSProfileInfo.h"


@interface FSUserManager : NSObject

+ (FSUserManager *)sharedManager;
- (FSProfileInfo *)currentProfile;

@end
