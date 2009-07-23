//
//  FinanceAppDelegate.m
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import "FinanceAppDelegate.h"
#import "ExpenseInputViewController.h"
#import "ExpensesTableViewController.h"

@implementation FinanceAppDelegate

@synthesize window;
@synthesize tabBarController;

#pragma mark -
#pragma mark Application life cycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	NSManagedObjectContext *context = [self managedObjectContext]; 
    if (!context) { 
        NSLog(@"Couldn't get a managedObjectContext");
    }
	
	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];

	self.tabBarController = [[UITabBarController alloc] initWithNibName:nil 
															bundle:nil]; 	

	ExpenseInputViewController * viewController1 = 
		[[[ExpenseInputViewController alloc] initWithNibName:@"AddExpense" bundle:[NSBundle mainBundle]] autorelease];
		
	ExpensesTableViewController * viewController2 = [[[ExpensesTableViewController alloc] initWithStyle:UITableViewStylePlain andContext:context] autorelease];
	
	viewController1.managedObjectContext = context;
	viewController2.managedObjectContext = context;

	// Create a navigation controller for the expenses view	
	UINavigationController * ctrl2NavCtrl = [[UINavigationController alloc] initWithRootViewController:viewController2];
	[[ctrl2NavCtrl navigationBar] setBarStyle:UIBarStyleBlackOpaque]; 
	
	[self.tabBarController setViewControllers:[NSArray arrayWithObjects:viewController1, ctrl2NavCtrl, nil]]; 
	[self.tabBarController setSelectedIndex:0];
	
	[context release];
	[ctrl2NavCtrl release];
	
	[window addSubview:self.tabBarController.view];

	[window makeKeyAndVisible];
	
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {

	// Don't want the app to save on close!
	// Make sure to save elsewhere!
	
//    NSError *error;
//    if (managedObjectContext != nil) {
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//			// Handle error
//			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//			exit(-1);  // Fail
//        } 
//    }
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
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


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Finance.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle error
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
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

