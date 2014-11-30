//
//  DataManager.h
//  nic
//
//  Created by Heikki Junnila on 29.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class Entity;

@protocol DataManagerDelegate <NSObject>
- (void) dataManager:(DataManager*)dataManager finishedFetchingEntities:(NSArray*)entities;
- (void) dataManagerFailedFetchingEntities:(DataManager*)dataManager;
@end

@interface DataManager : NSObject
@property (nonatomic, weak) id <DataManagerDelegate> delegate;

@property (nonatomic, strong, readonly) NSArray* entities;

+ (DataManager*)instance;
- (Entity*)getJohn;
- (Entity*)getNotJohn;
- (void) fetchEntities;
@end
