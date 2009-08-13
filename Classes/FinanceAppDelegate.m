//
//  FinanceAppDelegate.m
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import "FinanceAppDelegate.h"
#import "ExpenseInputViewController.h"
#import "TransactionsNavigationController.h"
#import "BetaViewController.h"
#import "Utilities.h"
#import "TransactionsMainViewController.h"
#import "SettingsViewController.h"
#import "TestController.h"

@implementation FinanceAppDelegate

@synthesize window;
@synthesize tabBarController;

#pragma mark -
#pragma mark Application life cycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	/*
	 Setup the utilities toolbox for use
	 */
	NSManagedObjectContext *utilitiesContext = [[NSManagedObjectContext alloc] init];
	[utilitiesContext setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
    if (!utilitiesContext) { 
        NSLog(@"Couldn't get a managedObjectContext for the utilities context");
    }
	// Give it a managed context for tags and locations
	[Utilities toolbox].managedObjectContext = utilitiesContext;
	[utilitiesContext release];

	
	NSManagedObjectContext *context = [self managedObjectContext]; 
    if (!context) { 
        NSLog(@"Couldn't get a managedObjectContext number 1");
    }
	TransactionsMainViewController * transactionViewController = 
		[[TransactionsMainViewController alloc] initWithNibName:@"TransactionFilterViewController" 
														  bundle:[NSBundle mainBundle]
													  andContext:context];
	//TransactionsViewController * transactionViewController = [[TransactionsViewController alloc] initWithContext:context];
	[context release];

	
	/*
	 Why does the addContext need a context of it's own?
	 There are several reasons:
	 * I don't want the temporary transactions to be autosaved
	 * I don't want the temporary transactions to show up in the table views
	 * I want to be able to make changes to transaction objects in the table views
		and have them autosaved on app termination
	 */
	NSManagedObjectContext *contextAddExpense = [[NSManagedObjectContext alloc] init];
	[contextAddExpense setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
    if (!contextAddExpense) { 
        NSLog(@"Couldn't get a managedObjectContext number 2 for addExpenseController");
    }
	ExpenseInputViewController * addExpenseController = 
		[[ExpenseInputViewController alloc] initWithNibName:@"ExpenseEditor" bundle:[NSBundle mainBundle]];
	// Pass it the managed object context that is only for its privte use :)
	addExpenseController.managedObjectContext = contextAddExpense;
	[contextAddExpense release];
	
	/*
	 We also give the beta screen a context of its own
	 */
	NSManagedObjectContext *contextBeta = [[NSManagedObjectContext alloc] init];
	[contextBeta setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
    if (!contextBeta) { 
        NSLog(@"Couldn't get a managedObjectContext number 2");
    }
	BetaViewController * betaController = [[BetaViewController alloc] initWithNibName:@"BetaViewController" bundle:[NSBundle mainBundle]];
	betaController.managedObjectContext = contextBeta;
	[contextBeta release];
	

	/*
	 Settings controller
	 */
	SettingsViewController * settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
	
	
	/*
	 TestController
	 */
	TestController * testController = [[TestController alloc] initWithNibName:@"TestController" bundle:[NSBundle mainBundle]];
	
	// Group all the view controllers
	NSArray * controllers = [NSArray arrayWithObjects:addExpenseController, transactionViewController, betaController, settingsController, testController, nil];

	// The control over the view controllers is now the business of the controllers array
	[transactionViewController release];
	[addExpenseController release];
	[betaController release];
	[settingsController release];
	[testController release];
	
	self.tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil]; 	
	[self.tabBarController setViewControllers:controllers]; 
	[self.tabBarController setSelectedIndex:0];
	
	[window addSubview:self.tabBarController.view];

	[window makeKeyAndVisible];
	
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
	NSLog(@"Application will terminate");
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
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
		NSLog(@"COULDN'T CREATE A PERSISTANT STORE COORDINATOR! CHAOS");
		NSLog(@"ERROR: %@", error);
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

