//
//  TransactionTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 24.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionTableViewController.h"

@implementation TransactionTableViewController

@synthesize resultsController;
@synthesize managedObjectContext;


#pragma mark -
#pragma mark Setup and teardown
- (id)initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext*)context {
	
	self = [super initWithStyle:style];
	
	if (self != nil) {
		self.managedObjectContext = context;
		self.resultsController = nil;
	}
	
	return self;
}
- (void)dealloc {
	NSLog(@"Deallocing %@", self);
	
	self.managedObjectContext = nil; // release
	self.resultsController = nil; // release
	
	[super dealloc];
}


#pragma mark -
#pragma mark NSFetchedResultsController delegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"%@ got sent a controllerDidChangeContent message. Reloading tableView data.", self);
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Powermethods for loading data from children
-(void)loadDataWithSortDescriptors:(NSArray*)sortDescriptors predicates:(NSPredicate*)predicate sectionNameKeyPath:(NSString*)sectionGroupingName cacheName:(NSString*)cacheName {
	
	// Only load data once...
	if (resultsController != nil) {NSLog(@"Trying to reload data...");return;} else {NSLog(@"Loading data for %@", self);}

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:managedObjectContext]; 

	// Create and setup the request
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	[request setEntity:entity];
	[request setSortDescriptors:sortDescriptors]; 
	[request setPredicate:predicate];
	
	NSError *error; 
	NSFetchedResultsController * localRC = [[NSFetchedResultsController alloc] 
											initWithFetchRequest:request 
											managedObjectContext:managedObjectContext 
											sectionNameKeyPath:sectionGroupingName cacheName:cacheName]; 
	// Has been retained by the localRC, so we can release it here.
	[request release];
	
	// Set self to delegate
	localRC.delegate=self;

	// Self takes control over the localRC, so we can release the local instance
	self.resultsController = localRC;
	[localRC release];
	
	// Get results
	if (![resultsController performFetch:&error]) { 
		NSLog(@"Error when performing fetch in %@", self);
		NSLog(@"ERROR: %@", error);
	}

	// Nothing to do if it worked :)
}	


#pragma mark -
#pragma mark To be implemented by subclasses
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Method called that should be implemented by child!");
	return 0;
}
- (void)updateData {
	NSLog(@"Method called that should be implemented by child!");
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Method called that should be implemented by child!");
	return nil;
}


@end
