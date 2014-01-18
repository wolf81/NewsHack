//
//  FSProfileInfo.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/26/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSProfileInfo.h"
#import "HTMLParser.h"


#define FS_PATH_PROFILE_FILE [FS_PATH_DOCUMENTS_DIR stringByAppendingPathComponent:@"profile.dat"]


@implementation FSProfileInfo

+ (FSProfileInfo *)profileInfoWithData:(NSData *)data error:(NSError **)error
{
    FSProfileInfo *profileInfo = [[FSProfileInfo alloc] init];
    if (profileInfo)
    {
        HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:error];
        HTMLNode *node = nil;
        
        if (!parser)
        {
            return nil;
        }
        
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        DLog(@"%@", string);
        
        // <a href="user?id=wsc981">wsc981</a>
        node = [parser.body findChildWithAttribute:@"href" matchingName:@"user?id=" allowPartial:YES];
        profileInfo.username = node ? node.allContents : nil;
        
        // <input type="text" name="email" value="wolfgang.schreurs@gmail.com"
        node = [parser.body findChildWithAttribute:@"name" matchingName:@"email" allowPartial:NO];
        profileInfo.email = node ? [node getAttributeNamed:@"value"] : nil;
        
        // <textarea cols="60" rows="5" wrap="virtual" name="about">
        node = [parser.body findChildWithAttribute:@"name" matchingName:@"about" allowPartial:NO];
        profileInfo.about = node ? node.allContents : nil;
        
        
        if (profileInfo.username == nil)
        {
            // try to figure out the cause of the error ...
            
            string = [parser.body allContents];
            NSRange range = [string rangeOfString:@"Bad login."];
            if (range.location != NSNotFound)
            {
                // incorrect username or password
                
                *error = [NSError errorWithDomain:FSNewsHackErrorDomain code:FSProfileBadLoginError];
            }
            else
            {
                 // we don't know WTF happened ...
                
                *error = [NSError errorWithDomain:FSNewsHackErrorDomain code:FSProfileParsingFailedError];
            }
            
            return nil;
        }
    }
    return profileInfo;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", self.username, self.email];
}

#pragma mark - Encoding / decoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_username forKey:@"_username"];
    [aCoder encodeObject:_email    forKey:@"_email"];
    [aCoder encodeObject:_about    forKey:@"_about"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.username = [aDecoder decodeObjectForKey:@"_username"];
        self.email    = [aDecoder decodeObjectForKey:@"_email"];
        self.about    = [aDecoder decodeObjectForKey:@"_about"];
    }
    return self;
}

#pragma mark - Public methods

+ (FSProfileInfo *)load
{
    FSProfileInfo *profileInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:FS_PATH_PROFILE_FILE];
    
    if (profileInfo)
    {
        DLog(@"Did load profile at path: %@", FS_PATH_PROFILE_FILE);
    }
    else
    {
        DLog(@"[WARNING] could not load profile from path: %@", FS_PATH_PROFILE_FILE);
    }

    return profileInfo;
}

- (void)store
{
    BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:FS_PATH_PROFILE_FILE];
    
    if (success)
    {
        DLog(@"Stored profile at path: %@", FS_PATH_PROFILE_FILE);
    }
    else
    {
        DLog(@"[ERROR] failed to store profile at path: %@", FS_PATH_PROFILE_FILE);
    }
}

+ (void)clear
{
    NSError *error   = nil;
    BOOL     success = [[NSFileManager defaultManager] removeItemAtPath:FS_PATH_PROFILE_FILE error:&error];
    
    if (success)
    {
        DLog(@"Deleted profile at path: %@", FS_PATH_PROFILE_FILE);
    }
    else
    {
        DLog(@"[ERROR] %@", error);
    }
}

@end
