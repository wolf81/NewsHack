//
//  FSError.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/27/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString *const FSNewsHackErrorDomain;


enum {
    FSUserNotLoggedInError = 1000,
    FSUserLogoutFailedError = 1001,
    FSProfileParsingFailedError = 1002,
    FSProfileBadLoginError = 1003,
    FSFNIDParsingFailedError = 1004,
    FSTooManyNewAccountsError = 1005,
    FSRegistrationFailedError = 1006,
    FSInvalidProductIdentifier = 1007,
    FSInvalidProductReceipt = 1008,
    FSProductPurchaseCancelledError = 1009,
    FSInAppPurchaseDisabledError = 1010,
    FSNoProductsAvailableError = 1011,
};
