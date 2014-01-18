//
//  FSTransaction.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/31/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSTransaction.h"


#define FS_PATH_TRANSACTION_FILE [FS_PATH_DOCUMENTS_DIR stringByAppendingPathComponent:@"transaction.dat"]


@interface FSTransaction ()

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSData   *receipt;

@end


@implementation FSTransaction

+ (FSTransaction *)transactionWithIdentifier:(NSString *)identifier receipt:(NSData *)receipt
{
    FSTransaction *transaction = [[FSTransaction alloc] init];
    if (transaction)
    {
        transaction.identifier = identifier;
        transaction.receipt    = receipt;
    }
    return transaction;
}

#pragma mark - Encoding / decoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.identifier = [aDecoder decodeObjectForKey:@"_identifier"];
        self.receipt    = [aDecoder decodeObjectForKey:@"_receipt"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_identifier forKey:@"_identifier"];
    [aCoder encodeObject:_receipt    forKey:@"_receipt"];
}

#pragma mark - Public methods

+ (FSTransaction *)load
{
    FSTransaction *transactionInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:FS_PATH_TRANSACTION_FILE];
    
    if (transactionInfo)
    {
        DLog(@"Did load profile at path: %@", FS_PATH_TRANSACTION_FILE);
    }
    else
    {
        DLog(@"[WARNING] could not load profile from path: %@", FS_PATH_TRANSACTION_FILE);
    }
    
    return transactionInfo;
}

- (void)store
{
    BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:FS_PATH_TRANSACTION_FILE];
    
    if (success)
    {
        DLog(@"Stored profile at path: %@", FS_PATH_TRANSACTION_FILE);
    }
    else
    {
        DLog(@"[ERROR] failed to store profile at path: %@", FS_PATH_TRANSACTION_FILE);
    }
}

+ (void)clear
{
    NSError *error   = nil;
    BOOL     success = [[NSFileManager defaultManager] removeItemAtPath:FS_PATH_TRANSACTION_FILE error:&error];
    
    if (success)
    {
        DLog(@"Deleted profile at path: %@", FS_PATH_TRANSACTION_FILE);
    }
    else
    {
        DLog(@"[ERROR] %@", error);
    }
}

@end
