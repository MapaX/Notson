//
//  AppDelegate.m
//  nic
//
//  Created by Heikki Junnila on 25.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <IBMCloudCode/IBMCloudCode.h>
#import <IBMFileSync/IBMFileSync.h>
#import <IBMBluemix/IBMBluemix.h>
#import <IBMData/IBMData.h>
#import <IBMPush/IBMPushAppMgr.h>

#import "ViewController.h"
#import "AppDelegate.h"
#import "MotionWindow.h"
#import "MyEconomicsMeViewController.h"
#import "MockingBird.h"
#import "DataManager.h"
#import "GAI.h"

#import <sys/utsname.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize selfie;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:( UIUserNotificationTypeBadge
            |UIUserNotificationTypeSound
            |UIUserNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    [application registerForRemoteNotifications];
    
    
    // Call this method to collect metrics when app is opened by clicking on push notification.
    [[IBMPushAppMgr get] appOpenedFromNotificationClick : launchOptions];
    self.window = [[MotionWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    ViewController* vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    
    // Use this instead of the vc above to bypass login
//    ViewController* vc = [[UIStoryboard storyboardWithName:@"MyEconomics" bundle:nil] instantiateViewControllerWithIdentifier:@"MyEconomicsViewController"];

    UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window setRootViewController:navi];

    [self.window makeKeyAndVisible];


    [self.window.rootViewController.navigationController pushViewController:vc animated:YES];
    [IBMBluemix initializeWithApplicationId:@"6eb08bfe-f493-4bad-8bcc-16dd78ad3b06" andApplicationSecret:@"61a938f211536290da477a0e621a08e155b09855" andApplicationRoute:@"notson.mybluemix.net"];
    
    [IBMData initializeService];
    [IBMFileSync initializeService];
    // Override point for customization after application launch.
    [application registerForRemoteNotifications];
    
    // Listen for shakes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceShake) name:@"DeviceShake" object:nil];

//    MockingBird* mb = [[MockingBird alloc] init];
//    [mb destroyPreviousData];
//    [mb createMockData];
    
    //Google anal-y-tics stuff
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 1;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-57208796-1"];
    
    // Dig out the device model. Thank you stack overflow
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      :@"Simulator",
                              @"iPod1,1"   :@"iPod Touch",      // (Original)
                              @"iPod2,1"   :@"iPod Touch",      // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch",      // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch",      // (Fourth Generation)
                              @"iPhone1,1" :@"iPhone",          // (Original)
                              @"iPhone1,2" :@"iPhone",          // (3G)
                              @"iPhone2,1" :@"iPhone",          // (3GS)
                              @"iPad1,1"   :@"iPad",            // (Original)
                              @"iPad2,1"   :@"iPad 2",          //
                              @"iPad3,1"   :@"iPad",            // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",        //
                              @"iPhone4,1" :@"iPhone 4S",       //
                              @"iPhone5,1" :@"iPhone 5",        // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",        // (model A1429, everything else)
                              @"iPad3,4"   :@"iPad",            // (4th Generation)
                              @"iPad2,5"   :@"iPad Mini",       // (Original)
                              @"iPhone5,3" :@"iPhone 5c",       // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5c",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5s",       // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5s",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPad4,1"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPad Mini",       // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini",        // (2nd Generation iPad Mini - Cellular)
                              @"iPhone7,1" :@"iPhone 6 Plus",
                              @"iPhone7,2" :@"iPhone 6"
                              };
    }
    
    NSString* deviceModel = [deviceNamesByCode objectForKey:code];
    
    if (!deviceModel) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceModel = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceModel = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceModel = @"iPhone";
        }
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Device"
                                                          action:@"Device model"
                                                           label:deviceModel
                                                           value:0] build]];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"selfie.png"]; //Add the file name
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:pngData];
    if (image) {
        self.selfie = image;
    }
    
    return YES;
}

- (void)deviceShake
{
    if ([[((UINavigationController *)self.window.rootViewController) visibleViewController] isKindOfClass:[UITabBarController class]])
    {
        if ([[((UITabBarController*)[((UINavigationController *)self.window.rootViewController) visibleViewController]) selectedViewController] isKindOfClass:[MyEconomicsMeViewController class]])
        {
            [((MyEconomicsMeViewController *)[((UITabBarController*)[((UINavigationController *)self.window.rootViewController) visibleViewController]) selectedViewController]) redrawBubbles];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

-(void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    

    self.pushService = [IBMPush initializeService];
    
    if(self.pushService != nil){
        [[self.pushService registerDevice:@"testalias" withConsumerId:@"testconsumerid" withDeviceToken:deviceToken.description]  continueWithBlock:^id(BFTask *task) {
            if(task.error){
                NSLog(@"failure");
            }else{
                NSLog(@"Success... ");
                //NSDictionary *result = task.result;
                
                [[self.pushService getSubscriptions] continueWithBlock:^id (BFTask *task){
                    if(task.error){
                        NSLog(@"Failure during getSubscriptions operation");
                    }else{
                        NSDictionary *subscriptions = [task.result objectForKey:@"subscriptions"];
                        if (subscriptions.count == 0){
                            [[self.pushService getTags] continueWithBlock:^id (BFTask *task) {
                                NSLog(@"Checking for available tags to subscribe.");
                                if (task.error){
                                    NSLog(@"Failure during getTags operation");
                                }else{
                                    NSArray* tags =[task.result objectForKey:@"tags"];
                                    //NSDictionary *result = task.result;
                                    if(tags.count == 0){
                                        NSLog(@"No tags are available for subscription");
                                    }else{
                                        NSLog(@"The following tags are available");
                                        //[self.appDelegateVC updateMessage:result.description];
                                        
                                        //subscribing to the first tag available.
                                        NSString *tag = [tags objectAtIndex:0];
                                        NSLog(@"Subscribing to tag: ");
                                        //[self.appDelegateVC updateMessage:tag];
                                        [[self.pushService subscribeToTag:tag] continueWithBlock:^id (BFTask *task){
                                            if (task.error){
                                                NSLog(@"Failure during tag subscription operation");
                                                //[self.appDelegateVC updateMessage:task.error.description];
                                            }else{
                                                NSLog(@"Successfully subscribed to tag:");
                                                //NSDictionary *result = task.result;
                                                //[self.appDelegateVC updateMessage: result.description];
                                            }
                                            return nil;
                                        }];
                                    }
                                }
                                
                                return nil;
                            }];
                            
                        }else{
                            NSLog(@"Device subscribed to the following tag(s).%@", subscriptions.description);
                            //[self.appDelegateVC updateMessage:subscriptions.description];
                        }
                        
                    }
                    return nil;
                }];
            }
            return nil;
        }];
    }else{
        NSLog(@"Push Service is nil. Possible wrong classname");
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token from APNS, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    // add this module to collect metrics for Notification received, Notification displayed and Notification clicked when app is in background.
    //[[IBMPushAppMgr get] notificationReceived : userInfo];
    
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        //[[IBMPushAppMgr get]appOpenedFromNotificationClickInBackground : userInfo];
    }
    NSDictionary* aps = [userInfo objectForKey:@"aps"];
    NSDictionary* alertDict = [aps objectForKey:@"alert"];
    NSString* alertText = [alertDict objectForKey:@"body"];
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Notification" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory
{
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.nordea.nic" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"nic" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"nic.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext
{
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
