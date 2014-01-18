//
//  FSInfoViewController.m
//  NewsHack
//
//  Created by Wolfgang Schreurs on 12/26/12.
//  Copyright (c) 2012 Wolfgang Schreurs. All rights reserved.
//

#import "FSInfoViewController.h"


#define FS_SECTION_HEADER_HEIGHT 100.0f

#define FS_COMPONENTS_INFO      @"NewsHack makes use of the following components:\n" \
                                @"- EGOTableViewPullRefresh by Enormego\n" \
                                @"- SMXMLDocument by Spotlight Mobile\n" \
                                @"- OHAttributedLabel by Olivier Halligon\n" \
                                @"- ABTableViewCell by Loren Brichter\n" \
                                @"- DejalActivityView by David Sinclair\n" \
                                @"- MarqueeLabel by Charles Powell\n" \
                                @"- HTMLParser by Ben Reeves\n" \
                                @"- AFNetworking by Gowalla\n" \
                                @"- EGOCache by Enormego\n" \
                                @"\nTab images are courtesy of Glyphish."


@interface FSInfoViewController ()

- (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font constraint:(CGSize)constraint origin:(CGPoint)origin;

@end


@implementation FSInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Info", @"Info");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.sectionHeaderHeight = FS_SECTION_HEADER_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.tableView hideHeaderView:YES];
    
    UIImage *image = FS_IMAGE_USER;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController)];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 0; 
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.font = FS_FONT_SMALL;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.backgroundColor = FS_COLOR_BACKGROUND;
        cell.backgroundView = backgroundView;
    }
    
    cell.textLabel.text = FS_COMPONENTS_INFO;
    
    return cell;
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    const CGRect bounds = self.view.bounds;
    CGRect frame        = CGRectMake(0.0f, 0.0f, bounds.size.width, FS_SECTION_HEADER_HEIGHT);
    
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor whiteColor];
    
    CGFloat   width      = self.view.bounds.size.width - (FS_FLOAT_PADDING * 2);
    CGFloat   y          = FS_FLOAT_PADDING;
    CGSize    constraint = CGSizeMake(width, CGFLOAT_MAX);
    NSString *text       = nil;
    CGPoint   origin     = CGPointMake(FS_FLOAT_PADDING, y);
    
    NSString *buildString   = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    text = [NSString stringWithFormat:@"NewsHack v%@ (%@)", versionString, buildString];
    
    UILabel *_titleLabel = [self labelWithText:text font:FS_FONT_BIG constraint:constraint origin:origin];
    [headerView addSubview:_titleLabel];
    
    NSDateFormatter *formatter     = [[NSDateFormatter alloc] init];
    formatter.dateFormat           = @"yyyy";
    NSDate          *date          = [NSDate date];
    NSString        *dateString    = [formatter stringFromDate:date];
    UILabel         *aboutAppLabel = nil;
    UIView          *seperatorView = nil;
    
    text          = [NSString stringWithFormat:@"Copyright \u00A9 %@ Felis Software\nDordrecht, The Netherlands", dateString];
    y            += (_titleLabel.frame.size.height + FS_FLOAT_PADDING);
    origin        = CGPointMake(FS_FLOAT_PADDING, y);
    aboutAppLabel = [self labelWithText:text font:FS_FONT_MEDIUM constraint:constraint origin:origin];
    [headerView addSubview:aboutAppLabel];
    
    y                             += aboutAppLabel.frame.size.height + FS_FLOAT_PADDING;
    seperatorView                  = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, bounds.size.width, 1.0f)];
    seperatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    seperatorView.backgroundColor  = FS_COLOR_BAR;
    [headerView addSubview:seperatorView];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    const CGRect bounds = self.tableView.bounds;
    CGFloat width = bounds.size.width - (FS_FLOAT_PADDING * 2);
    
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize size = [FS_COMPONENTS_INFO sizeWithFont:FS_FONT_SMALL constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height + (FS_FLOAT_PADDING * 2);
}

#pragma mark - Private methods

- (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font constraint:(CGSize)constraint origin:(CGPoint)origin
{
    CGSize size = [text sizeWithFont:font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frame           = CGRectMake(origin.x, origin.y, MAX(size.width, constraint.width), size.height);
    UILabel *label         = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment    = NSTextAlignmentCenter;
    label.lineBreakMode    = NSLineBreakByWordWrapping;
    label.numberOfLines    = 0;
    label.font             = font;
    label.text             = text;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor  = [UIColor clearColor];
    label.opaque           = YES;
    
    return label;
}

@end
