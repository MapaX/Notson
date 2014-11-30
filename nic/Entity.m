//
//  Entity.m
//  nic
//
//  Created by Heikki Junnila on 28.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "Entity.h"

@implementation Entity
@dynamic name;
@dynamic incomeThisPeriod;
@dynamic averagePeriodIncome;

+ (void) initialize
{
    [self registerSpecialization];
}

+ (NSString*) dataClassName
{
    return @"Entity";
}

#pragma mark - Transactions

- (void) fetchTransactions
{
    DLog();

    IBMDataRelation* rel = [self relationForKey:RELATION_TRANSACTION];
    IBMQuery *query = [rel query];
    [[query find] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            [self performSelectorOnMainThread:@selector(onTransactionsFetchError:) withObject:task.error waitUntilDone:NO];
        } else {
            NSArray *objects = (NSArray*) task.result;
            [self performSelectorOnMainThread:@selector(onTransactionsFetchSuccess:) withObject:objects waitUntilDone:YES];
        }
        return nil;
    }];
}

- (void) onTransactionsFetchSuccess:(NSArray*)transactions
{
    DLog();

    _transactions = transactions;

    if (self.delegate) {
        [self.delegate entity:self finishedFetchingTransactions:_transactions];
    }
}

- (void) onTransactionsFetchError:(NSError*)error
{
    DLog(@"Unable to get transactions for entity: %@. Reason: %@", self.name, error);

    if (self.delegate) {
        [self.delegate entityFailedFetchingTransactions:self];
    }
}

#pragma mark - Category Spending

- (void) fetchCategorySpending
{
    IBMDataRelation* rel = [self relationForKey:RELATION_CATEGORY_SPENDING];
    IBMQuery *query = [rel query];
    [[query find] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            [self performSelectorOnMainThread:@selector(onCategorySpendingFetchError:) withObject:task.error waitUntilDone:NO];
        } else {
            NSArray *objects = (NSArray*) task.result;
            [self performSelectorOnMainThread:@selector(onCategorySpendingFetchSuccess:) withObject:objects waitUntilDone:YES];
        }
        return nil;
    }];
}

- (void) onCategorySpendingFetchSuccess:(NSArray*)categorySpending
{
    DLog();

    _categorySpending = categorySpending;

    if (self.delegate) {
        [self.delegate entity:self finishedFetchingCategorySpending:_categorySpending];
    }
}

- (void) onCategorySpendingFetchError:(NSError*)error
{
    DLog(@"Unable to get category spending for entity: %@. Reason: %@", self.name, error);

    if (self.delegate) {
        [self.delegate entityFailedFetchingCategorySpending:self];
    }
}

@end
