//
//  Constants+Macros.h
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/23/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#ifndef NewsHack_Constants_Macros_h
#define NewsHack_Constants_Macros_h


// In-App purchase: we'll use the Sandbox environment for test versions ...

#if (DEBUG || RELEASE)
#define FS_URL_APPLE_VERIFY_RECEIPT [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"]
#else
#define FS_URL_APPLE_VERIFY_RECEIPT [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"]
#endif // (DEBUG || RELEASE)


// interface geometry: sizes of UI elements ...

#define FS_FLOAT_CELL_PADDING_VERTICAL  5.0f
#define FS_FLOAT_PADDING               10.0f
#define FS_FLOAT_SECTION_HEADER_HEIGHT 30.0f


// app defaults ...

#define FS_ANALYTICS_TRACKING_ID @"UA-37249220-1"
#define FS_STRING_BASE_URL       @"http://news.ycombinator.com"
#define FS_PATH_DOCUMENTS_DIR    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define FS_INTERVAL_CACHE_TIMEOUT  60 * 60


// style elements: fonts, colors, etc...

#define FS_STRING_FOOTER_VIEW   @"-o-"

#define FS_FLOAT_BACKGROUND_WHITE  0.97f

#define FS_COLOR_BAR          [UIColor colorWithRed:1.0f green:0.5f blue:0.0f alpha:1.0f]
#define FS_COLOR_BACKGROUND   [UIColor colorWithWhite:FS_FLOAT_BACKGROUND_WHITE alpha:1.0f]
#define FS_COLOR_CELL_SELECTED [UIColor colorWithWhite:0.0f alpha:1.0f]

#define FS_FONT_BIG           [UIFont fontWithName:@"Avenir-Black"         size:18]
#define FS_FONT_MEDIUM        [UIFont fontWithName:@"Avenir-Black"         size:16]
#define FS_FONT_MEDIUM_ITALIC [UIFont fontWithName:@"Avenir-LightOblique"  size:16]
#define FS_FONT_SMALL         [UIFont fontWithName:@"Avenir-Book"          size:14]
#define FS_FONT_SMALL_ITALIC  [UIFont fontWithName:@"Avenir-LightOblique"  size:14]

#define FS_IMAGE_USER         [UIImage imageNamed:@"user"]
#define FS_IMAGE_CHAT_DARK    [UIImage imageNamed:@"chat-dark"]
#define FS_IMAGE_CHAT_LIGHT   [UIImage imageNamed:@"chat"]
#define FS_IMAGE_NEWS         [UIImage imageNamed:@"news"]


// debug logging (disable logging for release builds ...

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...) /* disable logging for release and distribution builds */
#endif // DEBUG


// error handling ...

#define FS_ERROR_KEY(code)                    [NSString stringWithFormat:@"%d", code]
#define FS_ERROR_LOCALIZED_DESCRIPTION(code)  NSLocalizedStringFromTable(FS_ERROR_KEY(code), @"FSError", nil)

#endif
