//
//  MockingBird.m
//  nic
//
//  Created by Heikki Junnila on 29.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <stdlib.h>

#import "CategorySpending.h"
#import "MockingBird.h"
#import "Transaction.h"
#import "Entity.h"

#define SECS_PER_MINUTE (60)
#define SECS_PER_HOUR (60 * SECS_PER_MINUTE)
#define SECS_PER_DAY (24 * SECS_PER_HOUR)
#define SECS_PER_YEAR (365 * SECS_PER_DAY)

@interface MockingBird ()
@property (nonatomic, strong) NSArray* cats;
@end

@implementation MockingBird

- (id) init
{
    self = [super init];
    if (self) {
        self.cats = @[CAT_CAR, CAT_FOOD, CAT_HOME, CAT_LEISURE, CAT_SAVINGS, CAT_SPORTS];
    }
    return self;
}

- (void) destroyPreviousData
{
    // Destroy entities
    IBMQuery *query = [Entity query];
    [[query find] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            DLog(@"Error while getting entities: %@", task.error);
        } else {
            NSArray *objects = (NSArray*) task.result;
            DLog(@"Got %lu entities", (unsigned long)objects.count);
            [self performSelectorOnMainThread:@selector(destroyDataWithObjects:) withObject:objects waitUntilDone:YES];
        }
        return nil;
    }];

    // Destroy category spending
    query = [CategorySpending query];
    [[query find] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            DLog(@"Error while getting category spendings: %@", task.error);
        } else {
            NSArray *objects = (NSArray*) task.result;
            DLog(@"Got %lu category spendings", (unsigned long)objects.count);
            [self performSelectorOnMainThread:@selector(destroyDataWithObjects:) withObject:objects waitUntilDone:YES];
        }
        return nil;
    }];
 
    // Destroy transactions
    query = [Transaction query];
    [[query find] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            DLog(@"Error while getting transactions: %@", task.error);
        } else {
            NSArray *objects = (NSArray*) task.result;
            DLog(@"Got %lu transactions", (unsigned long)objects.count);
            [self performSelectorOnMainThread:@selector(destroyDataWithObjects:) withObject:objects waitUntilDone:YES];
        }
        return nil;
    }];
}

- (void) destroyDataWithObjects:(NSArray*)objects
{
    for (IBMDataObject* o in objects) {
        [[o delete] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                DLog(@"Delete failed");
            } else {
                DLog(@"Delete succeeded");
            }
            return nil;
        }];
    }
}

- (void) createMockData
{
    Entity* person = [self createPerson];
    IBMDataRelation* rel = [person relationForKey:RELATION_CATEGORY_SPENDING];
    for (int i = 0; i < self.cats.count; i++) {
        CategorySpending* cs = [[CategorySpending alloc] init];
        cs.amount = [NSString stringWithFormat:@"%d.%d", (arc4random()%(400-200))+200, random(100)];
        cs.averageSpending = [NSString stringWithFormat:@"%d.%d", (arc4random()%(400-300))+300, random(100)];
        cs.category = [self.cats objectAtIndex:i];

        [[cs save] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                DLog(@"CategorySpending %d save failed: %@", i, task.error);
            } else {
                DLog(@"Created CategorySpending #%d", i);
            }
            return nil;
        }];

        [rel addObject:cs];
    }

    rel = [person relationForKey:RELATION_TRANSACTION];
    for (int c = 0; c < self.cats.count; c++) {
        NSString* category = [self.cats objectAtIndex:c];
        for (int i = 0; i < 20; i++) {
            Transaction* tr = [self createRandomPaymentForCategory:category];
            [[tr save] continueWithBlock:^id(BFTask *task) {
                if (task.error) {
                    DLog(@"Transaction %d save failed: %@", i, task.error);
                } else {
                    DLog(@"Created Transaction #%d", i);
                }
                return nil;
            }];
            [rel addObject:tr];
        }
    }

    [[person save] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            DLog(@"person %@ entity save failed: %@", person.name, task.error);
        } else {
            Entity* another = (Entity*)task.result;
            DLog(@"Created/updated entity called: %@", another.name);
        }
        return nil;
    }];

    // Peers
    Entity* peers = [self createPeerGroup];
    [[peers save] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            DLog(@"peer group %@ entity save failed: %@", peers.name, task.error);
        } else {
            Entity* another = (Entity*)task.result;
            DLog(@"Created/updated peer group called: %@", another.name);
        }
        return nil;
    }];

    rel = [peers relationForKey:RELATION_CATEGORY_SPENDING];
    for (int i = 0; i < self.cats.count; i++) {
        CategorySpending* cs = [[CategorySpending alloc] init];
        cs.amount = [NSString stringWithFormat:@"%d.%d", (arc4random()%(400-200))+200, random(100)];
        cs.averageSpending = [NSString stringWithFormat:@"%d.%d", (arc4random()%(400-300))+300, random(100)];
        cs.category = [self.cats objectAtIndex:i];
        
        [[cs save] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                DLog(@"CategorySpending %d save failed: %@", i, task.error);
            } else {
                DLog(@"Created CategorySpending #%d", i);
            }
            return nil;
        }];
        
        [rel addObject:cs];
    }
}

- (void) createImages
{
}

- (Transaction*) createRandomPaymentForCategory:(NSString*)category
{
    Transaction* tr = [[Transaction alloc] init];
    int dec = random(100);
    int frac = random(100);
    tr.amount = [NSString stringWithFormat:@"%d.%d", dec, frac];
    
    tr.date = [[NSDate date] dateByAddingTimeInterval:(random(SECS_PER_YEAR))];
    tr.category = category;

    if ([category isEqualToString:CAT_FOOD]) {
        NSArray* foods = @[@"ICA", @"Starbucks", @"McDonalds"];
        tr.name = [foods objectAtIndex:random(3)];
    } else {
        NSArray* stores = @[@"Åhlens", @"Peak", @"Sagaform"];
        tr.name = [stores objectAtIndex:random(3)];
    }

    tr.longitude = [NSString stringWithFormat:@"25.%d", random(1000)];
    tr.latitude = [NSString stringWithFormat:@"65.%d", random(1000)];
    
    return tr;
}

- (Entity*) createPerson
{
    Entity* e = [[Entity alloc] init];
    e.name = @"John Doewater";
    e.incomeThisPeriod = [NSString stringWithFormat:@"%d.%d", random(5000) + 1000, random(100)];
    e.averagePeriodIncome = [NSString stringWithFormat:@"%d.%d", random(5000) + 1000, random(100)];
    return e;
}

- (Entity*) createPeerGroup
{
    Entity* e = [[Entity alloc] init];
    e.name = @"John's peers";
    e.incomeThisPeriod = [NSString stringWithFormat:@"%d.%d", random(5000) + 1000, random(100)];
    e.averagePeriodIncome = [NSString stringWithFormat:@"%d.%d", random(5000) + 1000, random(100)];
    return e;
}

- (CategorySpending*) createCategorySpending
{
    CategorySpending* cs = [[CategorySpending alloc] init];
    cs.amount = [NSString stringWithFormat:@"%d.%d", random(100) + 1, random(100)];
    cs.category = [self.cats objectAtIndex:random(self.cats.count)];

    return cs;
}

@end
