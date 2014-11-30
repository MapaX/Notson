//
//  Entity.h
//  nic
//
//  Created by Heikki Junnila on 28.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IBMData/IBMData.h>

#define RELATION_CATEGORY_SPENDING @"categorySpending"
#define RELATION_TRANSACTION @"transaction"

@class Entity;

@protocol EntityDelegate <NSObject>
@optional
- (void) entityFailedFetchingTransactions:(Entity*)Entity;
- (void) entity:(Entity*)entity finishedFetchingTransactions:(NSArray*)transactions;

- (void) entityFailedFetchingCategorySpending:(Entity*)Entity;
- (void) entity:(Entity*)entity finishedFetchingCategorySpending:(NSArray*)categorySpending;
@end

@interface Entity : IBMDataObject <IBMDataObjectSpecialization>
@property (nonatomic, weak) id <EntityDelegate> delegate;

@property (nonatomic, copy) NSString* name;                                 // Name of the entity (person or peer group)
@property (nonatomic, copy) NSString* incomeThisPeriod;                     // Income amount for this period
@property (nonatomic, copy) NSString* averagePeriodIncome;                  // Average income per period (e.g. over a year)

@property (nonatomic, strong, readonly) NSArray* categorySpending;          // Money spent in this period per category
@property (nonatomic, strong, readonly) NSArray* transactions;              // All transactions

- (void) fetchTransactions;
- (void) fetchCategorySpending;

@end
