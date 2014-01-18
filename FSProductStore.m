//
//  FSAppStore.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/30/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSProductStore.h"
#import <StoreKit/StoreKit.h>
#import "NSData+Base64.h"
#import "AFNetworking.h"
#import "FSTransaction.h"
#import "GAI.h"


@interface FSProductStore () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (void)startTransaction:(SKPaymentTransaction *)transaction;
- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;
- (void)validateReceipt:(NSData *)receiptData withCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

- (void)purchaseSuccess:(NSString *)productIdentifier;
- (void)purchaseFailedWithError:(NSError *)error;

@property (nonatomic, strong) SKProductsRequest *currentProductRequest;
@property (nonatomic, copy) void (^completionHandler)(BOOL success, NSError *error);

@end


@implementation FSProductStore

+ (FSProductStore *)defaultStore
{
    static FSProductStore *store;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!store)
        {
            store = [[FSProductStore alloc] init];
        }
    });
    
    return store;
}

- (void)registerObserver
{
    DLog(@"registering observer ...");
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

#pragma mark - Products request delegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (!response.products || response.products.count == 0)
    {
        NSError *error = [NSError errorWithDomain:FSNewsHackErrorDomain code:FSNoProductsAvailableError];
        [self purchaseFailedWithError:error];
    }
    else
    {
        SKProduct *product = response.products[0];
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        
        if ([SKPaymentQueue canMakePayments])
        {
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
        else
        {
            NSError *error = [NSError errorWithDomain:FSNewsHackErrorDomain code:FSInAppPurchaseDisabledError];
            [self purchaseFailedWithError:error];
        }
        DLog(@"%@", response.products);
    }
}

#pragma mark - Payment transaction observer

// Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    DLog(@"%@", transactions);
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        DLog(@"%@", transaction);
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing: [self startTransaction:transaction];    break;
            case SKPaymentTransactionStateFailed:     [self failedTransaction:transaction];   break;
            case SKPaymentTransactionStatePurchased:  [self completeTransaction:transaction]; break;
            case SKPaymentTransactionStateRestored:   [self restoreTransaction:transaction];  break;
            default: break;
        }
    }
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    DLog(@"%@", error);
    
    [self purchaseFailedWithError:error];
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    DLog(@"%@", transactions);
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    DLog(@"%@", queue);
}

// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    DLog(@"%@", downloads);
}


#pragma mark - Public methods

- (void)startProductRequestWithIdentifier:(NSString *)productIdentifier
                        completionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    if ([productIdentifier isEqualToString:FS_PRODUCT_DISABLE_ADS] == NO)
    {
        DLog(@"ERROR: invalid product identifier!");
        
        NSError *error = [NSError errorWithDomain:FSNewsHackErrorDomain code:FSInvalidProductIdentifier];
        
        if (completionHandler)
        {
            completionHandler(NO, error);
        }
        
        return;
    }
    
    
    // cancel any existing product request (if exists) ...
    
    [self cancelProductRequest];
    
    
    // start new  request ...
    
    self.completionHandler = completionHandler;
    
    NSSet *productIdentifiers = [NSSet setWithObject:productIdentifier];
    self.currentProductRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _currentProductRequest.delegate = self;
    [_currentProductRequest start];
}

- (void)cancelProductRequest
{
    if (_currentProductRequest)
    {
        DLog(@"cancelling existing request ...");
        
        [_currentProductRequest setDelegate:nil];
        [_currentProductRequest cancel];
    }
}

#pragma mark - Private methods

- (void)startTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"starting transaction: %@", transaction);
}

- (void)completeTransaction: (SKPaymentTransaction *)transaction
{
    [self validateReceipt:transaction.transactionReceipt withCompletionHandler:^ (BOOL success, NSError *error) {
        if (success)
        {
            [self recordTransaction:transaction];
            [self purchaseSuccess:transaction.payment.productIdentifier];
            
            [self onPurchaseCompleted:transaction];
        }
        else
        {
            // deal with error ...
            [self purchaseFailedWithError:error];
        }
        
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }];
}

- (void)failedTransaction: (SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    if (transaction.error.code != SKErrorPaymentCancelled) {
        [self purchaseFailedWithError:transaction.error];
    }
    else
    {
        [self purchaseFailedWithError:nil];
    }
}

- (void)restoreTransaction: (SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self purchaseSuccess:transaction.originalTransaction.payment.productIdentifier];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"recording transaction: %@", transaction);
    
    
    // TODO: store for audit trail - perhaps on remote server?
    
    FSTransaction *transactionToRecord = [FSTransaction transactionWithIdentifier:transaction.transactionIdentifier receipt:transaction.transactionReceipt];
    [transactionToRecord store];
}

- (void)purchaseSuccess:(NSString *)productIdentifier
{
    // TODO: make purchase available to user - perhaps call completion block?
    
    DLog(@"transaction success for product: %@", productIdentifier);
    
    self.currentProductRequest = nil;
    
    if (_completionHandler)
    {
        _completionHandler(YES, nil);
    }
}

- (void)purchaseFailedWithError:(NSError *)error
{
    DLog(@"%@", error);
    
    self.currentProductRequest = nil;
    
    if (_completionHandler)
    {
        _completionHandler(NO, error);
    }
}

- (void)validateReceipt:(NSData *)receiptData withCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    DLog(@"validating receipt with Apple ...");
    
    NSString *body = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", [receiptData base64EncodedString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:FS_URL_APPLE_VERIFY_RECEIPT];
    request.HTTPMethod = @"POST";
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^ (NSURLRequest *request, NSURLResponse *response, id JSON) {
        
        DLog(@"%@", JSON);
        
        NSNumber *number  = [JSON objectForKey:@"status"];
        BOOL      success = number && (number.integerValue == 0);
        NSError  *error   = success ? nil : [NSError errorWithDomain:FSNewsHackErrorDomain code:FSInvalidProductReceipt];
        
        if (completionHandler)
        {
            completionHandler(success, error);
        }
        
    } failure:^ (NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
        
        if (completionHandler)
        {
            completionHandler(NO, error);
        }
        
    }];
    [operation start];
}

- (void)onPurchaseCompleted:(SKPaymentTransaction *)transaction
{
    if (transaction.originalTransaction != nil)
    {
        return; // existing transaction ...
    }
    
    GAITransaction *GANTransaction = [GAITransaction transactionWithId:transaction.transactionIdentifier withAffiliation:@"In-App Store"]; // (NSString) Transaction ID, should be unique.
    GANTransaction.taxMicros       = (int64_t)(0 * 1000000);    // (int64_t) Total tax (in micros)
    GANTransaction.shippingMicros  = (int64_t)(0);              // (int64_t) Total shipping (in micros)
    GANTransaction.revenueMicros   = (int64_t)(0.89 * 1000000); // (int64_t) Total revenue (in micros)
    
    [GANTransaction addItemWithCode:@"newshack01"
                               name:@"Disable Ads"
                           category:nil
                        priceMicros:(int64_t)(0.89 * 1000000)
                           quantity:1];
    
    [[GAI sharedInstance].defaultTracker trackTransaction:GANTransaction]; // Track the transaction.
}

@end
