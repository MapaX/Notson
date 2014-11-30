//
//  MySpendingDetailsViewController.m
//  nic
//
//  Created by Heikki Junnila on 29.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MySpendingDetailsViewController.h"
#import "TransactionTableViewCell.h"
#import "UIView+Extension.h"
#import "PieChartView.h"
#import "LoadingView.h"
#import "DataManager.h"
#import "Transaction.h"
#import "LegendView.h"
#import "Entity.h"

@interface MySpendingDetailsViewController () <UITableViewDataSource, UITableViewDelegate, EntityDelegate>
@property (nonatomic, weak) IBOutlet PieChartView* pie;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UIView* topView;
@property (nonatomic, weak) IBOutlet UIView* legendContainer;
@property (nonatomic, weak) Entity* entity;
@property (nonatomic, weak) id <EntityDelegate> previousDelegate;
@property (nonatomic, strong) NSMutableArray* categoryTransactions;
@end

@implementation MySpendingDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.entity = [[DataManager instance] getJohn];
    self.previousDelegate = self.entity.delegate;
    self.entity.delegate = self;
    [LoadingView show];
    [self.entity fetchTransactions];

    [self.tableView registerNib:[UINib nibWithNibName:@"TransactionTableViewCell" bundle:nil] forCellReuseIdentifier:[TransactionTableViewCell cellId]];
    
    UIView* filler = [[UIView alloc] initWithFrame:self.topView.bounds];
    [self.tableView setTableHeaderView:filler];

    [self.topView setBackgroundColor:[UIColor whiteColor]];

    [self setTitle:self.category.uppercaseString];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.navigationController.navigationBar setTranslucent:NO];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

    NSString* str = @"DISTRIBUTION, LAST 6 MONTHS";
    NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange range = {0, 12};
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont boldSystemFontOfSize:17]
                 range:range];
    [self.titleLabel setAttributedText:attr];
}

- (void) viewWillDisappear:(BOOL)animated
{
    DLog();

    [super viewWillDisappear:animated];
    self.entity.delegate = self.previousDelegate;
    self.entity = nil;
    self.previousDelegate = nil;
}

- (IBAction) onDone:(id)sender
{
    DLog();
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EntityDelegate

- (void) entity:(Entity *)entity finishedFetchingTransactions:(NSArray *)transactions
{
    DLog(@"Got %lu transactions", (unsigned long)transactions.count);
    NSMutableArray* array = [NSMutableArray new];
    for (Transaction* tr in entity.transactions) {
        if ([tr.category isEqualToString:self.category]) {
            [array addObject:tr];
        }
    }

    [LoadingView dismiss];
    
    NSSortDescriptor *dateDesc = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:dateDesc, nil];
    self.categoryTransactions = [NSMutableArray arrayWithArray:array];
    [self.categoryTransactions sortUsingDescriptors:sortDescriptors];

    NSDateFormatter* form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"M"];
    NSString* currentMonth = [form stringFromDate:[NSDate date]];

    NSCalendar* cal = [NSCalendar currentCalendar];

    NSArray* colors = @[UIColorFromRGB(0x00DB26), UIColorFromRGB(0x08B8EE), UIColorFromRGB(0xA6D92A), UIColorFromRGB(0x515151), UIColorFromRGB(0xBAA5D1), UIColorFromRGB(0xD2E9F3)];

    NSMutableArray* values = [NSMutableArray new];
    CGFloat y = 0;
    NSDictionary* totals = [self createMonthlyTotals];
    for (int i = 0; i < 6; i++) {
        NSString* mon = [NSString stringWithFormat:@"%d", currentMonth.intValue - i];
        NSNumber* total = [totals objectForKey:mon];
        if (!total) {
            total = [NSNumber numberWithFloat:0.0f];
        }

        [values addObject:total];
    
        LegendView* legend = [[LegendView alloc] initWithFrame:CGRectMake(0, y, 92, 35)];
        [self.legendContainer addSubview:legend];
        y += legend.frame.size.height;
        [legend setupWithValue:[NSString stringWithFormat:@"%.2f", total.floatValue] title:[cal.shortMonthSymbols objectAtIndex:currentMonth.intValue - i - 1] color:[colors objectAtIndex:i] darkenText:NO];
    }

    [self.pie setZeroAngle:DEGREES_TO_RADIANS(PIE_ZERO_ANGLE_DEGREES)];
    [self.pie setValues:[NSArray arrayWithArray:values]];
    [self.pie setColors:colors];
    
    [self.pie animateIntoViewAsPlaceholder:NO];
    
    CGRect r = self.legendContainer.frame;
    CGFloat x = r.origin.x;
    r.origin.x = self.topView.frame.size.width;
    self.legendContainer.frame = r;
    [UIView animateWithDuration:0.5
                     animations:^(void) {
                         CGRect r = self.legendContainer.frame;
                         r.origin.x = x;
                         self.legendContainer.frame = r;
                     }
                     completion:^(BOOL completion) {
                     }
     ];
    
    [self.tableView reloadData];
}

- (void) entityFailedFetchingTransactions:(Entity *)entity
{
    DLog();
    [LoadingView dismiss];
}

- (NSDictionary*) createMonthlyTotals
{
    DLog();
    NSDateFormatter* form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"M"];

    NSMutableDictionary* months = [NSMutableDictionary new];
    for (Transaction* tr in self.categoryTransactions) {
        NSString* month = [form stringFromDate:tr.date];
        NSNumber* monthlyTotal = [months objectForKey:month];
        if (!monthlyTotal) {
            monthlyTotal = [NSNumber numberWithFloat:0];
        }

        float val = monthlyTotal.floatValue + tr.amount.floatValue;
        [months setObject:[NSNumber numberWithFloat:val] forKey:month];
    }
    
    return [NSDictionary dictionaryWithDictionary:months];
}

#pragma mark - UITableViewDataSource

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect headerRect = self.topView.frame;
    headerRect.origin.y = CLAMP(0 - offset.y, -(self.topView.frame.size.height), 0);
    [self.topView setFrame:headerRect];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categoryTransactions.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectInset(view.frame, 10, 0)];
    [view addSubview:label];

    NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"TRANSACTIONS CATEGORIZED AS %@", self.category.uppercaseString]];
    NSRange range = {0, 12};
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont boldSystemFontOfSize:17]
                 range:range];
    [label setAttributedText:attr];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setNumberOfLines:0];
    
    UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(0, 42, 320, 2)];
    [sep setBackgroundColor:UIColorFromRGB(0xf2f2f2)];
    [view addSubview:sep];
    
    return view;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[TransactionTableViewCell cellId] forIndexPath:indexPath];
    if (!cell) {
        cell = [[TransactionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[TransactionTableViewCell cellId]];
    }

    Transaction* tr = [self.categoryTransactions objectAtIndex:indexPath.row];
    [cell setTransaction:tr];

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

@end
