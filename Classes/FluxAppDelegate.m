//
//  FluxAppDelegate.m
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import "FluxAppDelegate.h"
#import "Utilities.h"
#import "OverviewTableViewController.h"
#import "AddTransactionController.h"
#import "TagSelector.h"
#import "TabBarController.h"
#import "NewOverviewTableViewController.h"
#import "NewDetailTableViewController.h"
#import "TransactionViewController.h"

@implementation FluxAppDelegate

@synthesize window;
@synthesize tabBarController;

#pragma mark -
#pragma mark Application life cycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	/*
	 Navigation controller
	 In my next app it will all be written using one!
	 In this I'll just have to fase things over slowly
	 */
	TTNavigator* navigator = [TTNavigator navigator];
  navigator.persistenceMode = TTNavigatorPersistenceModeAll;
  navigator.window = self.window;

	
	TTURLMap* map = navigator.URLMap;
	[map from:@"*" toViewController:[TTWebController class]]; // Fall back URL
	[map from:@"kleio://tagSelector" toModalViewController:[TagSelector class]];
	[map from:@"kleio://tabBar" toSharedViewController:[TabBarController class]];
	[map from:@"kleio://listTransactions" toSharedViewController:[OverviewTableViewController class]];
	[map from:@"kleio://addTransaction" toSharedViewController:[AddTransactionController class]];
	[map from:@"kleio://newTransactionList" toSharedViewController:[NewOverviewTableViewController class]];
	[map from:@"kleio://showMonth/(initWithMonth:)" toViewController:[NewDetailTableViewController class]];
	[map from:@"kleio://showTransaction" toViewController:[TransactionViewController class]];
	
	[navigator openURL:@"kleio://tabBar" animated:NO];

}
- (void)applicationWillTerminate:(UIApplication *)application {
	
	// Forcefully remove the singleton classes
	[[CacheMasterSingleton sharedCacheMaster] dealloc];
	[[Utilities toolbox] dealloc];
	
	NSError *error;
	if (managedObjectContext != nil) {
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		} 
	}
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Core data

#pragma mark -
#pragma mark Core Data stack
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
		
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Finance.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle error
		NSLog(@"COULDN'T CREATE A PERSISTANT STORE COORDINATOR! CHAOS");
		NSLog(@"ERROR: %@", error);
	}    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma mark
#pragma mark -
#pragma mark Memory management


- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
		
		[tabBarController release];
    [window release];
	
    [super dealloc];
}

@end

