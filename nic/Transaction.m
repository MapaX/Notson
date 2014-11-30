//
//  Transaction.m
//  nic
//
//  Created by Heikki Junnila on 29.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction
@dynamic date;
@dynamic name;
@dynamic amount;
@dynamic latitude;
@dynamic longitude;
@dynamic category;

+ (void) initialize
{
    [self registerSpecialization];
}

+ (NSString*) dataClassName
{
    return @"Transaction";
}

- (UIImage*) image
{
    NSString* name = self.name;
    if ([self.name isEqualToString:@"Åhlens"]) {
        name = @"Ahlens";
    }
    return [UIImage imageNamed:name];
}

@end
