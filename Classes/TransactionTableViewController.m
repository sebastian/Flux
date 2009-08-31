//
//  TransactionTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 24.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionTableViewController.h"
#import "Utilities.h"
#import "KleioSearchBar.h"

@interface TransactionTableViewController (PrivateMethods)
- (void)clearCacheIfAvailable;
- (void)clearCacheIfAvailableForIndexPath:(NSIndexPath*)indexPath;
- (void)toggleSearch;
- (void)updatePredicate:(NSNotification*)notification;
- (void)staleCache:(NSNotification*)notification;
@end



@implementation TransactionTableViewController

@synthesize resultsController;
@synthesize managedObjectContext;

@synthesize	filteringPredicate;
@synthesize filteredSearchResults;
@synthesize worthUpdating;

#pragma mark -
#pragma mark Setup and teardown
- (id)initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext*)context {
	self = [super initWithStyle:style];
	if (self != nil) {
		self.managedObjectContext = context;
		self.filteringPredicate = [NSPredicate predicateWithValue:YES];
		
		self.worthUpdating = YES;
		
		/*
		 If we don't start listening for cache changes
		 already on the init, then we miss insertions of new
		 transactions that occure before the overview page has been visited!
		 */
/*		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(clearCacheIfAvailable)
			name:@"FinanceKillAllCache"
			object:nil];		*/
		
	}	
	return self;
}
- (void)dealloc {
//	NSLog(@"Unregistering observer %@", self);
//	[[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	NSLog(@"Deallocing %@", self);
	
	// Release all resources
	self.managedObjectContext = nil;
	self.resultsController = nil;
	self.filteringPredicate = nil;
	self.filteredSearchResults = nil;
	
	[super dealloc];
}
- (void)viewDidLoad {
	
	UIBarButtonItem * searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch 
																				   target:self 
																				   action:@selector(toggleSearch)];
	if ([self navigationItem].rightBarButtonItem != nil) {
		self.navigationItem.rightBarButtonItem = searchButton;	
	}
	[searchButton release];
	
	// Register to get a notification whenever the predicate is changed!
//	[[NSNotificationCenter defaultCenter]
//		addObserver:self
//		selector:@selector(updatePredicate:)
//		name:@"KleioPredicateUpdated"
//		object:nil];
//
//	[[NSNotificationCenter defaultCenter]
//		addObserver:self.tableView
//		selector:@selector(reloadData)
//		name:@"GlobalTableViewReloadData"
//		object:nil];		
	
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.backgroundColor = [UIColor clearColor];
}
- (void)viewDidUnload {
	
	//NSLog(@"View Did Unload called in %@", self);
	// Remove from NotificationCenter
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

- (NSFetchedResultsController*)resultsController {
	if (resultsController == nil) {
		NSLog(@"Creating and loading data for the resultsController in %@", self);
		[self updateData];
	}
	return resultsController;
}


#pragma mark
#pragma mark -
#pragma mark Private methods
-(void)toggleSearch {
	// Send show notification
	[[KleioSearchBar searchBar] toggle];
}
-(void)updatePredicate:(NSNotification*)notification {

	// Store the new predicate
	NSDictionary * predicateDict = notification.userInfo;
	
	if (![self.filteringPredicate isEqual:[predicateDict objectForKey:@"predicate"]]) {
		self.filteringPredicate = [predicateDict objectForKey:@"predicate"];
			
		[self clearCacheIfAvailable];
		
		// Reload data :)
		NSLog(@"RELOADING DATA: %@", self);
		[self.tableView reloadData];
		
	} 
}
- (void)clearCacheIfAvailable {
	if ([self respondsToSelector:@selector(clearDataCache)]) {
		[self performSelector:@selector(clearDataCache)];
		NSLog(@"Clearing all cache in %@", self);
	} else {
		NSLog(@"ERROR: Could not find clearDataCache method in %@", self);
	}
}
- (void)clearCacheIfAvailableForIndexPath:(NSIndexPath*)indexPath {
	if ([self respondsToSelector:@selector(clearDataCacheForIndexPath:)]) {
		[self performSelector:@selector(clearDataCacheForIndexPath:) withObject:indexPath];
	} else {
		NSLog(@"Does not respond to clearCacheForIndexPath");
	}
}



#pragma mark -
#pragma mark Powermethods for loading data from children
-(void)loadDataWithSortDescriptors:(NSArray*)sortDescriptors predicates:(NSPredicate*)predicate sectionNameKeyPath:(NSString*)sectionGroupingName cacheName:(NSString*)cacheName {
	
	// Only load data once...
	if (resultsController != nil) {
		NSLog(@"Trying to reload data...");
		NSLog(@"\tNot allowed! Returning");
		return;
		
	} else {NSLog(@"Loading data for %@", self);}

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

	// DONE
}	

- (void) updateIfWorthIt {
	if (self.worthUpdating) {
		NSLog(@"Reloading tableview data, because it is worth it :) (%@)", self);
		[self.tableView reloadData];
		self.worthUpdating = NO;
	} else {
		NSLog(@"Not worth the hassle reloading table view data.");
	}
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


- (void)didReceiveMemoryWarning {
	NSLog(@"didReceiveMemoryWarning: %@", self);
	
	NSLog(@"Clearing cache in %@ to help", self);
	[self clearCacheIfAvailable];
	
    [super didReceiveMemoryWarning];
}

@end
