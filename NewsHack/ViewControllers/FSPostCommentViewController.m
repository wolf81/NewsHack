//
//  FSPostCommentViewController.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/25/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSPostCommentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FSCommentsLoader.h"


@interface FSPostCommentViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIToolbar  *toolbar;
@property (nonatomic, assign) NSInteger   itemIdentifier;

- (void)unregisterForKeyboardNotifications;
- (void)registerForKeyboardNotifications;
- (void)postButtonTouched:(id)sender;
- (void)cancelButtonTouched:(id)sender;
- (BOOL)isValidText;

- (UIBarButtonItem *)flexItem;
- (UIBarButtonItem *)activityItem;
- (UIBarButtonItem *)postButtonItem;
- (UIBarButtonItem *)cancelButtonItem;

@end


@implementation FSPostCommentViewController

- (id)initWithItemIdentifier:(NSInteger)identifier
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.itemIdentifier = identifier;
        self.trackedViewName = NSLocalizedString(@"Post Comment", nil);
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _textView.delegate = nil;
    [_textView resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    const CGRect bounds = self.view.bounds;
    
    CGFloat toolbarHeight = 40.0f;
    CGFloat width = bounds.size.width - (FS_FLOAT_PADDING * 2);
    CGFloat height = bounds.size.height - (FS_FLOAT_PADDING * 2) - toolbarHeight;
    CGRect frame = CGRectMake(FS_FLOAT_PADDING, FS_FLOAT_PADDING, width, height);
    
    self.textView = [[UITextView alloc] initWithFrame:frame];
    _textView.font = FS_FONT_MEDIUM;
    [self.view addSubview:_textView];
    
    CGFloat y = bounds.size.height - toolbarHeight;
    frame = CGRectMake(0.0f, y, bounds.size.width, toolbarHeight);
    self.toolbar = [[UIToolbar alloc] initWithFrame:frame];
    _toolbar.tintColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    _toolbar.items     = @[[self cancelButtonItem], [self flexItem], [self postButtonItem]];
    
    _textView.inputAccessoryView  = _toolbar;
    _textView.layer.cornerRadius  = 5.0f;
    _textView.layer.masksToBounds = YES;
    _textView.autocorrectionType  = UITextAutocorrectionTypeNo;
    _textView.returnKeyType       = UIReturnKeyDefault;

    [self registerForKeyboardNotifications];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [self unregisterForKeyboardNotifications];
    
    self.textView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated]; 

    [_textView becomeFirstResponder];
    _textView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text view delegate

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return NO;
}

#pragma mark - Handling keyboard notifcations / view resizing depending on orientation 

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSNumber *kbHeight;
    
    NSDictionary* info = [aNotification userInfo];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        kbHeight = [NSNumber numberWithFloat:[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.width];
    }
    else {
        kbHeight = [NSNumber numberWithFloat:[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height];
    }
    
    const CGRect bounds = self.view.bounds;
    CGFloat width = bounds.size.width - (FS_FLOAT_PADDING * 2);
    CGFloat height = bounds.size.height - kbHeight.floatValue - (FS_FLOAT_PADDING * 2);
    
    _textView.frame = CGRectMake(FS_FLOAT_PADDING, FS_FLOAT_PADDING, width, height);
}

#pragma mark - Private methods

- (void)cancelButtonTouched:(id)sender
{
    [[FSCommentsLoader sharedLoader] cancel];
    [self dismissViewController];
    
    if (_completionHandler)
    {
        _completionHandler(NO);
    }
}

- (void)postButtonTouched:(id)sender
{
    if ([self isValidText] == NO)
    {
        NSString *title = @"Comment too short";
        NSString *message = @"Please enter a bit more text ...";
        NSString *buttonText = @"OK";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:buttonText otherButtonTitles:nil];
        [alert show];
                
        return;
    }

    
    DLog(@"current item: %d", _itemIdentifier);

    [self showLoadingIndicator:YES forView:_textView];
    
    [[FSCommentsLoader sharedLoader] postComment:_textView.text withParentIdentifier:_itemIdentifier completionHandler:^ (BOOL success, NSError *error) {
        
        DLog(@"%d %@", success, error);

        if (success)
        {
            _toolbar.items = @[[self flexItem],[self labelItemWithText:@"Comment posted successfully."], [self flexItem]];
            
            [self performSelector:@selector(dismissViewController) withObject:self afterDelay:1.0f];
            
            if (_completionHandler)
            {
                _completionHandler(YES);
            }
        }
        else
        {
            [UIAlertView showAlertViewWithError:error delegate:nil];
        }
    }];
}

- (void)showLoadingIndicator:(BOOL)showIndicator
{
    _textView.editable = !showIndicator;
    
    if (showIndicator)
    {
        _toolbar.items = @[[self cancelButtonItem], [self flexItem], [self labelItemWithText:@"Posting, please wait ..."], [self activityItem]];
    }
    else
    {
        _toolbar.items = @[[self cancelButtonItem], [self flexItem], [self postButtonItem]];
    }
}

- (UIBarButtonItem *)flexItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)postButtonItem
{
    UIBarButtonItem *postButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(postButtonTouched:)];
    
    postButtonItem.tintColor = FS_COLOR_BAR;
    
    return postButtonItem;
}

- (UIBarButtonItem *)labelItemWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.font = FS_FONT_MEDIUM_ITALIC;
    [label sizeToFit];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    
    return [[UIBarButtonItem alloc] initWithCustomView:label];
}

- (UIBarButtonItem *)cancelButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTouched:)];
}

- (UIBarButtonItem *)activityItem
{
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.frame = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    [activityView startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    return activityItem;
}

- (BOOL)isValidText
{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *string = [_textView.text stringByTrimmingCharactersInSet:charSet];
    
    return (string.length > 3);
}

@end
