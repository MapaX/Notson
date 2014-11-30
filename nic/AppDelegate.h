//
//  AppDelegate.h
//  nic
//
//  Created by Heikki Junnila on 25.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <IBMPush/IBMPush.h>
#import "MotionWindow.h"

#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "GAI.h"

#define kSimulatedEstimationFactor 31/27
#define kUserName @"userName"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) MotionWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong)IBMPush *pushService;
@property (nonatomic, strong) UIImage *selfie;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

