//
//  CategorySpending.m
//  nic
//
//  Created by Heikki Junnila on 29.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "CategorySpending.h"

@implementation CategorySpending
@dynamic amount;
@dynamic category;
@dynamic averageSpending;

+ (void) initialize
{
    [self registerSpecialization];
}

+ (NSString*) dataClassName
{
    return @"CategorySpending";
}

@end
