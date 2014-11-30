//
//  DataManager.m
//  nic
//
//  Created by Heikki Junnila on 29.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <IBMData/IBMData.h>
#import "DataManager.h"
#import "Entity.h"

static DataManager* instance_ = nil;

@implementation DataManager

+ (DataManager*)instance
{
    if (!instance_) {
        instance_ = [[DataManager alloc] init];
    }
    return instance_;
}

- (Entity*)getJohn
{
    for (int i = 0; i < self.entities.count; i++) {
        Entity* e = [self.entities objectAtIndex:i];
        if ([e.name containsString:@"John Doewater"]) {
            return e;
        }
    }
    
    return nil;
}

- (Entity*)getNotJohn
{
    for (int i = 0; i < self.entities.count; i++) {
        Entity* e = [self.entities objectAtIndex:i];
        if (![e.name containsString:@"John Doewater"]) {
            return e;
        }
    }
    
    return nil;
}

- (void) fetchEntities
{
    IBMQuery *query = [Entity query];
    [[query find] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            DLog(@"Error while getting entities: %@", task.error);
            [self performSelectorOnMainThread:@selector(onEntitiesFetchFailed) withObject:nil waitUntilDone:NO];
        } else {
            NSArray *objects = (NSArray*) task.result;
            DLog(@"Got %lu entities", (unsigned long) objects.count);
            [self performSelectorOnMainThread:@selector(onEntitiesFetchSuccess:) withObject:objects waitUntilDone:YES];
        }
        return nil;
    }];
}

- (void) onEntitiesFetchSuccess:(NSArray*)entities
{
    DLog();
    _entities = entities;
    if (self.delegate) {
        [self.delegate dataManager:self finishedFetchingEntities:_entities];
    }
}

- (void) onEntitiesFetchFailed
{
    DLog();
    if (self.delegate) {
        [self.delegate dataManagerFailedFetchingEntities:self];
    }
}

@end
