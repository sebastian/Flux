//
//  TransactionsViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 24.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionsNavigationController.h"
#import "OverviewTableViewController.h"
#import "DetailTableViewController.h"
#import "Transaction.h"
#import "Utilities.h"

@implementation TransactionsNavigationController

@synthesize managedObjectContext;
- (NSManagedObjectContext*)managedObjectContext {
	if (managedObjectContext == nil) {
		managedObjectContext = [[[Utilities toolbox] createObjectContext] retain];
	}
	return managedObjectContext;
}

-(id)initWithRootViewController:(id)rootviewcontroller {
	
	if (self = [super initWithRootViewController:rootviewcontroller]) {
		
		// Setting the delegate to self so that I can inform the views that they will be appearing
		self.delegate = self;
		
		// Setup style
		self.navigationBar.barStyle = UIBarStyleBlackOpaque;
		
		// Needed so that I can receive the info about changes in the managedObjectContext and
		// propagate them!
		self.title = NSLocalizedString(@"Transactions", @"Transaction table view header");
				
	}	
		
	
//	// Create a managed object context
//	managedObjectContext = [[[Utilities toolbox] createObjectContext] retain];
//	
//	OverviewTableViewController * overviewController = 
//		[[OverviewTableViewController alloc] initWithStyle:UITableViewStylePlain andContext:managedObjectContext];
//	
////	NSLog(@"Updating data in background thread (synchronized)");
////	[overviewController performSelectorInBackground:@selector(updateData) withObject:nil];
//	
//	self = [super initWithRootViewController:overviewController];
//	[overviewController release];
//	
//	if (self != nil) {	
//		// Setting the delegate to self so that I can inform the views that they will be appearing
//		self.delegate = self;
//		
//		// Setup style
//		self.navigationBar.barStyle = UIBarStyleBlackOpaque;
//
//		// Needed so that I can receive the info about changes in the managedObjectContext and
//		// propagate them!
//		self.title = NSLocalizedString(@"Transactions", @"Transaction table view header");
//	}
	
	return self;
}

-(void)viewDidLoad {
	[super viewDidLoad];
		
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(objectContextUpdated:)
	 name:NSManagedObjectContextDidSaveNotification
	 object:nil];
	
}
-(void)viewDidUnload {
	
	NSLog(@"View DID UNLOAD called for nav controller");
	
	// Remove as observer
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super viewDidUnload];
}

- (void)objectContextUpdated:(NSNotification *)notification {
	[self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];	
}

- (void)dealloc {
	self.managedObjectContext = nil; // release
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
	NSLog(@"didReceiveMemoryWarning: %@", self);
    [super didReceiveMemoryWarning];
}


#pragma mark
#pragma mark -
#pragma mark NavigationControllerDelegate method 
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[viewController viewWillAppear:animated];
}
@end
