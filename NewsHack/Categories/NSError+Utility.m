//
//  NSError+Utility.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/29/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "NSError+Utility.h"


@implementation NSError (Utility)

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code
{
    NSDictionary *userInfo = nil;
    
    if (domain == FSNewsHackErrorDomain)
    {
        // try to find the localized error message
        //  if there is none defined, use Apple's default error message based
        //  on app domain and error code ...
        
        NSString *text    = FS_ERROR_LOCALIZED_DESCRIPTION(code);
        BOOL      isValid = [text isEqualToString:FS_ERROR_KEY(code)] == NO;
        userInfo          = isValid ? @{NSLocalizedDescriptionKey : text} : nil;
    }
    
    return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

@end
