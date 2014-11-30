//
//  CategorySpending.h
//  nic
//
//  Created by Heikki Junnila on 29.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <IBMData/IBMData.h>

@interface CategorySpending : IBMDataObject <IBMDataObjectSpecialization>
@property (nonatomic, copy) NSString* amount;   // Amount spent to the category
@property (nonatomic, copy) NSString* category; // Category
@property (nonatomic, copy) NSString* averageSpending;  // Average amount spent per month
@end
