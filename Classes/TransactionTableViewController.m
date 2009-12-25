//
//  TransactionTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 24.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionTableViewController.h"
#import "Utilities.h"
#import "DetailTableViewController.h"
#import "OverviewTableViewController.h"
#import "CacheMasterSingleton.h"

@implementation TransactionTableViewController

@synthesize resultsController;
@synthesize managedObjectContext;

@synthesize	filteringPredicate;
@synthesize filteredSearchResults;
@synthesize worthUpdating;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id)initWithStyle:(UITableViewStyle)style {

	if (self = [super initWithStyle:style]) {
		
		self.filteringPredicate = [NSPredicate predicateWithValue:YES];
		
		self.worthUpdating = YES;
		
		/*
		 Set the cache delegate
		 */
//		if ([self class] == [OverviewTableViewController class]) {
//			[[CacheMasterSingleton sharedCacheMaster] setOverviewTableDelegate:(OverviewTableViewController*)self];
//		} else if ([self class] == [DetailTableViewController class]) {
//			[[CacheMasterSingleton sharedCacheMaster] setDetailTableDelegate:(DetailTableViewController*)self];
//		}
				
	}	
	return self;
}

- (id) initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext *)context {
	self = [self initWithStyle:style];
	[self setManagedObjectContext:context];
	return self;
}

- (id) init {
	
	self = [self initWithStyle:UITableViewStylePlain];
	[self.tabBarItem setImage:[UIImage imageNamed:@"Transactions.png"]];
	self.tabBarItem.title = NSLocalizedString(@"List", nil);
	
	return self;
	
}

- (void)dealloc {
	NSLog(@"Deallocing %@", self);
	
	// Release all resources
	self.managedObjectContext = nil;
	self.resultsController = nil;
	self.filteringPredicate = nil;
	self.filteredSearchResults = nil;
	
	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UITableView

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor = RGBACOLOR(50,50,50,0.6); 
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

}

- (void)didReceiveMemoryWarning {
	NSLog(@"didReceiveMemoryWarning: %@", self);
	
	NSLog(@"Clearing cache in %@ to help", self);
	[[CacheMasterSingleton sharedCacheMaster] clearCache];
	
	[super didReceiveMemoryWarning];
}	


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	CoreData

- (NSFetchedResultsController*)resultsController {
	if (resultsController == nil) {
		NSLog(@"Creating and loading data for the resultsController in %@", self);
		[self updateData];
	}
	return resultsController;
}

- (void)loadDataWithSortDescriptors:(NSArray*)sortDescriptors predicates:(NSPredicate*)predicate sectionNameKeyPath:(NSString*)sectionGroupingName cacheName:(NSString*)cacheName {
	
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
		//NSLog(@"ERROR: %@", error);
	}

	// DONE
}	

- (void) updateIfWorthIt {
	if (self.worthUpdating) {
		NSLog(@"Reloading tableview data, because it is worth it :) (%@)", self);
		[self.tableView reloadData];
		self.worthUpdating = NO;
		
		/*
		 Update the filtering button, 
		 it might just as well be that it has been updated!
		 */
		self.navigationItem.rightBarButtonItem = [[CacheMasterSingleton sharedCacheMaster] filterButton];
		
	} else {
		NSLog(@"Not worth the hassle reloading table view data. (%@)", self);
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	To be implemented by children

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
