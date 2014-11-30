//
//  TransactionTableViewCell.m
//  nic
//
//  Created by Heikki Junnila on 30.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "TransactionTableViewCell.h"
#import "Transaction.h"

@interface TransactionTableViewCell ()
@property (nonatomic, weak ) IBOutlet UIImageView* icon;
@property (nonatomic, weak ) IBOutlet UILabel* name;
@property (nonatomic, weak ) IBOutlet UILabel* type;
@property (nonatomic, weak ) IBOutlet UILabel* amount;
@property (nonatomic, weak ) IBOutlet UILabel* date;
@end

@implementation TransactionTableViewCell

+ (NSString*) cellId
{
    return @"TransactionTableViewCell";
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setTransaction:(Transaction*) transaction
{
    DLog();

    [self.icon setImage:[transaction image]];
    [self.name setText:transaction.name];
    [self.amount setText:transaction.amount];
    [self.type setText:@""];

    NSDateFormatter* form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"dd.MM.yyyy"];
    [self.date setText:[form stringFromDate:transaction.date]];
}

@end
