//
//  MockingBird.h
//  nic
//
//  Created by Heikki Junnila on 29.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MockingBird : NSObject
- (void) destroyPreviousData;
- (void) createMockData;
@end
