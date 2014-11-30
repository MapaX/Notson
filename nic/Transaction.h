//
//  Transaction.h
//  nic
//
//  Created by Heikki Junnila on 29.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <IBMData/IBMData.h>

#define CAT_FOOD @"food"
#define CAT_LEISURE @"leisure"
#define CAT_SAVINGS @"savings"
#define CAT_HOME @"home"
#define CAT_SPORTS @"sports"
#define CAT_CAR @"car"

@class Transaction;
@class Entity;

@interface Transaction : IBMDataObject <IBMDataObjectSpecialization>
@property (nonatomic, copy) NSDate* date;                   // Date of transaction
@property (nonatomic, copy) NSString* name;                 // Name of the place
@property (nonatomic, copy) NSString* amount;               // Amount used in the transaction
@property (nonatomic, copy) NSString* category;             // Transaction category
@property (nonatomic, copy) NSString* longitude;            // Where something was bought from
@property (nonatomic, copy) NSString* latitude;             // Where something was bought from
- (UIImage*) image;
@end
