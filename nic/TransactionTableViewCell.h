//
//  TransactionTableViewCell.h
//  nic
//
//  Created by Heikki Junnila on 30.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Transaction;

@interface TransactionTableViewCell : UITableViewCell

+ (NSString*) cellId;
- (void) setTransaction:(Transaction*) transaction;

@end
