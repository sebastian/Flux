//
//  TransactionTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 24.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionTableViewController.h"
#import "Utilities.h"
#import "FilterField.h"

@interface TransactionTableViewController (PrivateMethods)
-(void)toggleSearch;
-(void)updatePredicate:(NSNotification*)notification;
@end



@implementation TransactionTableViewController

@synthesize resultsController;
@synthesize managedObjectContext;

@synthesize	filteringPredicate;
@synthesize filteredSearchResults;

#pragma mark -
#pragma mark Setup and teardown
- (id)initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext*)context {
	self = [super initWithStyle:style];
	if (self != nil) {
		self.managedObjectContext = context;
		self.filteringPredicate = [NSPredicate predicateWithValue:YES];
	}	
	return self;
}
- (void)dealloc {
	NSLog(@"Deallocing %@", self);
	
	self.managedObjectContext = nil; // release
	self.resultsController = nil; // release
	self.filteringPredicate = nil;
	self.filteredSearchResults = nil;
	
	[super dealloc];
}
- (void)viewDidLoad {
	UIBarButtonItem * searchButton = 
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch 
													  target:self 
													  action:@selector(toggleSearch)];
	self.navigationItem.rightBarButtonItem = searchButton;
	[searchButton release];
	
	// Register to get a notification whenever the predicate is changed!
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(updatePredicate:)
		name:@"KleioPredicateUpdated"
		object:nil];
	
}
- (void)viewDidUnload {
	
	// Remove from NotificationCenter
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}


#pragma mark
#pragma mark -
#pragma mark Private methods
-(void)toggleSearch {
	// Send show notification
	[[FilterField sharedFilterBar] toggle];
}
-(void)updatePredicate:(NSNotification*)notification {

	// Store the new predicate
	NSDictionary * predicateDict = notification.userInfo;
	self.filteringPredicate = [predicateDict objectForKey:@"predicate"];
	
	[self updateFilteredDataArray];
	
	// Reload data :)
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark NSFetchedResultsController delegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"%@ got sent a controllerDidChangeContent message. Reloading tableView data.", self);
	
	[self updateFilteredDataArray];
	[self.tableView reloadData];
}

- (void) updateFilteredDataArray {
	NSLog(@"Updated the filtered data array");
	self.filteredSearchResults = [[resultsController fetchedObjects] filteredArrayUsingPredicate:self.filteringPredicate];
}


#pragma mark -
#pragma mark Powermethods for loading data from children
-(void)loadDataWithSortDescriptors:(NSArray*)sortDescriptors predicates:(NSPredicate*)predicate sectionNameKeyPath:(NSString*)sectionGroupingName cacheName:(NSString*)cacheName {
	
	// Only load data once...
	if (resultsController != nil) {NSLog(@"Trying to reload data...");} else {NSLog(@"Loading data for %@", self);}

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

	// Get the filtered result, in case there is a filter
	[self updateFilteredDataArray];
	
	// DONE
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
