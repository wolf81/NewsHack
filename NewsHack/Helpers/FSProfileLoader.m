//
//  FSProfileLoader.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/26/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSProfileLoader.h"
#import "AFNetworking.h"
#import "FSNewsLoader.h"
#import "HTMLParser.h"


@interface FSProfileLoader ()

- (void)retrieveFNIDWithCompletionHandler:(void (^)(NSString *FNID, NSError *error))completionHandler;
- (void)retrieveFNIDWithUsername:(NSString *)username completionHandler:(void (^)(NSString *FNID, NSError *error))completionHandler;
- (void)retrieveFNIDForRegistrationWithCompletionHandler:(void (^)(NSString *FNID, NSError *error))completionHandler;

@end


@implementation FSProfileLoader

+ (FSProfileLoader *)sharedLoader
{
    static FSProfileLoader *loader;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!loader)
        {
            loader = [[FSProfileLoader alloc] init];
        }
    });
    
    return loader;
}

- (void)cancel
{
    [[NSOperationQueue currentQueue] cancelAllOperations];
}

- (void)registerWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{    
    // first logout user - just in case ...
    
    [self logoutWithCompletionHandler:^ (BOOL success, NSError *error) {
        
        if (success)
        {
            [self retrieveFNIDForRegistrationWithCompletionHandler:^ (NSString *FNID, NSError *error) {
                
                DLog(@"%@ %@", FNID, error);
                
                if (FNID)
                {
                    
                }
                
                NSURL                  *baseURL    = [NSURL URLWithString:FS_STRING_BASE_URL];
                AFHTTPClient           *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
                NSDictionary           *params     = @{@"fnid" : FNID, @"u" : username, @"p" : password};
                NSMutableURLRequest    *request    = [httpClient requestWithMethod:@"POST" path:@"/x" parameters:params];
                AFHTTPRequestOperation *operation  = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                
                
                // handle redirects - HackerNews will redirect to some page defined in a previous request ...
                
                [AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(300, 3)]];
                [operation setRedirectResponseBlock:^ NSURLRequest* (NSURLConnection *connection, NSURLRequest *request, NSURLResponse *response) {
                    
                    DLog(@"redirecting to: %@", request.URL);
                    
                    return request;
                    
                }];
                
                
                // load profile data and parse ...
                
                [operation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSData        *data    = (NSData *)responseObject;
                    NSError       *error   = nil;
                    NSString      *string  = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
                    BOOL           success = (string != nil);
                    
                    if (success)
                    {
                        DLog(@"%@", string);
                        NSRange range = string ? [string rangeOfString:@"Hacker News | Submit"] : NSMakeRange(NSNotFound, 0);
                        success       = range.location != NSNotFound; // login success ...
                        
                        if (!success)
                        {
                            range  = [string rangeOfString:@"Too many new accounts."];
                            error  = ((range.location != NSNotFound)
                                      ? [NSError errorWithDomain:FSNewsHackErrorDomain code:FSTooManyNewAccountsError]
                                      : [NSError errorWithDomain:FSNewsHackErrorDomain code:FSRegistrationFailedError]);
                        }
                    }
                    
                    if (completionHandler)
                    {
                        completionHandler(success, error);
                    }
                    
                } failure:^ (AFHTTPRequestOperation *operation, NSError *error) {
                    
                    if (completionHandler)
                    {
                        completionHandler(NO, error);
                    }
                    
                }];
                
                [[NSOperationQueue currentQueue] addOperation:operation];
                
                
            }];
        }
        else // won't be able to register when we're logged in ...
        {
            completionHandler(NO, error);
        }
        
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(FSProfileInfo *profileInfo, NSError *error))completionHandler
{
    [self retrieveFNIDWithUsername:username completionHandler:^ (NSString *FNID, NSError *error) {
        
        DLog(@"%@ %@", FNID, error);
        
        NSURL                  *baseURL    = [NSURL URLWithString:FS_STRING_BASE_URL];
        AFHTTPClient           *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        NSDictionary           *params     = @{@"fnid" : FNID, @"u" : username, @"p" : password};
        NSMutableURLRequest    *request    = [httpClient requestWithMethod:@"POST" path:@"/y" parameters:params];
        AFHTTPRequestOperation *operation  = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        
        // handle redirects - HackerNews will redirect to some page defined in a previous request ...
        
        [AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(300, 3)]];
        [operation setRedirectResponseBlock:^ NSURLRequest* (NSURLConnection *connection, NSURLRequest *request, NSURLResponse *response) {
            
            DLog(@"redirecting to: %@", request.URL);
            
            return request;
            
        }];
        
        
        // load profile data and parse ...
        
        [operation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id responseObject) {
            
            NSData        *data        = (NSData *)responseObject;
            NSError       *error       = nil;
            FSProfileInfo *profileInfo = [FSProfileInfo profileInfoWithData:data error:&error];
            
            if (completionHandler)
            {
                completionHandler(profileInfo, error);
            }
            
        } failure:^ (AFHTTPRequestOperation *operation, NSError *error) {
            
            if (completionHandler)
            {
                completionHandler(nil, error);
            }
            
        }];
        
        [[NSOperationQueue currentQueue] addOperation:operation];
    }];
    
}

- (void)logoutWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    [self retrieveFNIDWithCompletionHandler:^ (NSString *FNID, NSError *error) {
        
        DLog(@"%@ %@", FNID, error);
        
        if (FNID == nil)
        {
            // logout was not necessary anymore, user wasn't logged in anyway,
            //  we'll return no error ...
            
            BOOL success = [error.domain isEqualToString:FSNewsHackErrorDomain] && error.code == FSUserNotLoggedInError;
            
            if (completionHandler)
            {
                completionHandler(success, error);
            }
            
            return;
        }
        
        
        NSString               *URLString = [NSString stringWithFormat:@"%@/r?fnid=%@", FS_STRING_BASE_URL, FNID];
        NSURL                  *URL       = [NSURL URLWithString:URLString];
        NSURLRequest           *request   = [NSURLRequest requestWithURL:URL];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        DLog(@"%@", URLString);
        
        [operation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id responseObject) {
            
            NSData     *data    = (NSData *)responseObject;
            NSError    *error   = nil;
            HTMLParser *parser  = [[HTMLParser alloc] initWithData:data error:&error];
            BOOL        success = (parser != nil);
            
            if (parser)
            {
                HTMLNode *node = [parser.body findChildWithAttribute:@"href" matchingName:@"newslogin" allowPartial:YES];
                success        = node != nil;
                error          = success ? nil : [NSError errorWithDomain:FSNewsHackErrorDomain code:FSUserLogoutFailedError];
            }
            
            if (completionHandler)
            {
                completionHandler(success, error);
            }
            
        } failure:^ (AFHTTPRequestOperation *operation, NSError *error) {
            
            if (completionHandler)
            {
                completionHandler(NO, error);
            }
        }];
        
        [[NSOperationQueue currentQueue] addOperation:operation];
    }];
}


- (void)retrieveFNIDWithCompletionHandler:(void (^)(NSString *FNID, NSError *error))completionHandler
{
    NSURL                  *URL       = [NSURL URLWithString:FS_STRING_BASE_URL];
    NSURLRequest           *request   = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString   *FNID   = nil;
        NSData     *data   = (NSData *)responseObject;
        NSError    *error  = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
        
        if (parser)
        {
            HTMLNode *node   = [parser.body findChildWithAttribute:@"href" matchingName:@"/r?fnid=" allowPartial:YES];
            NSString *string = [node getAttributeNamed:@"href"];
            NSRange range    = string ? [string rangeOfString:@"="] : NSMakeRange(NSNotFound, 0);
            FNID             = range.location != NSNotFound ? [string substringFromIndex:range.location + 1] : nil;
            error            = FNID ? nil : [NSError errorWithDomain:FSNewsHackErrorDomain code:FSUserNotLoggedInError];
        }
        
        if (completionHandler)
        {
            completionHandler(FNID, error);
        }
        
    } failure:^ (AFHTTPRequestOperation *operation, NSError *error) {
        
        if (completionHandler)
        {
            completionHandler(nil, error);
        }
        
    }];
    
    [[NSOperationQueue currentQueue] addOperation:operation];
}

- (void)retrieveFNIDWithUsername:(NSString *)username completionHandler:(void (^)(NSString *FNID, NSError *error))completionHandler
{
    // a URL like the following is used: http://news.ycombinator.com/newslogin?whence={encoded-value}
    //  the 'whence' value is used for redirecting after login,
    //  this value needs to be encoded by percent escaping all characters
    //  the default ObjC encoder fails, so the CoreFoundation encoder is used
    
    NSString *unencodedString = [NSString stringWithFormat:@"user?id=%@", username];
    NSString *encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                           NULL,
                                                                                           (CFStringRef)unencodedString,
                                                                                           NULL,
                                                                                           (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                           kCFStringEncodingUTF8 );
    
    NSString     *URLString = [NSString stringWithFormat:@"%@/newslogin?whence=%@", FS_STRING_BASE_URL, encodedString];
    NSURL        *URL       = [NSURL URLWithString:URLString];
    NSURLRequest *request   = [NSURLRequest requestWithURL:URL];
    
    DLog(@"%@", URLString);
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString   *FNID   = nil;
        NSData     *data   = (NSData *)responseObject;
        NSError    *error  = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
        
        if (parser)
        {
            HTMLNode *node = [parser.body findChildWithAttribute:@"name" matchingName:@"fnid" allowPartial:NO];
            FNID           = [node getAttributeNamed:@"value"];
            error          = FNID ? nil : [NSError errorWithDomain:FSNewsHackErrorDomain code:FSFNIDParsingFailedError];
        }
        
        if (completionHandler)
        {
            completionHandler(FNID, error);
        }
        
    } failure:^ (AFHTTPRequestOperation *operation, NSError *error) {
        
        if (completionHandler)
        {
            completionHandler(nil, error);
        }
        
    }];
    
    [[NSOperationQueue currentQueue] addOperation:operation];
}

- (void)retrieveFNIDForRegistrationWithCompletionHandler:(void (^)(NSString *FNID, NSError *error))completionHandler
{
    NSString               *URLString = [NSString stringWithFormat:@"%@/submit", FS_STRING_BASE_URL];
    NSURL                  *URL       = [NSURL URLWithString:URLString];
    NSURLRequest           *request   = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    DLog(@"%@", URLString);
    
    [operation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString   *FNID   = nil;
        NSData     *data   = (NSData *)responseObject;
        NSError    *error  = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
        
        if (parser)
        {            
            HTMLNode *node = [parser.body findChildWithAttribute:@"value" matchingName:@"create account" allowPartial:NO];
            node           = (node && node.parent != nil) ? node.parent : nil;
            node           = node ? [node findChildWithAttribute:@"name" matchingName:@"fnid" allowPartial:NO] : nil;
            FNID           = [node getAttributeNamed:@"value"];
            error          = FNID ? nil : [NSError errorWithDomain:FSNewsHackErrorDomain code:FSFNIDParsingFailedError];
        }
        
        if (completionHandler)
        {
            completionHandler(FNID, error);
        }
        
    } failure:^ (AFHTTPRequestOperation *operation, NSError *error) {
        
        if (completionHandler)
        {
            completionHandler(nil, error);
        }
    }];
    
    [[NSOperationQueue currentQueue] addOperation:operation];
}

@end
