//
//  TransactionTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 24.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionTableViewController.h"

@interface TransactionTableViewController (Private)
-(void)doReloadData:(id)param;
@end


@implementation TransactionTableViewController

@synthesize resultsController;
@synthesize managedObjectContext;

// Method needed by children
-(void)loadDataWithSortDescriptors:(NSArray*)sortDescriptors predicates:(NSPredicate*)predicate sectionNameKeyPath:(NSString*)sectionGroupingName cacheName:(NSString*)cacheName {
	
	// Load the expenses
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" 
											  inManagedObjectContext:self.managedObjectContext]; 
	[request setEntity:entity];
	
	[request setSortDescriptors:sortDescriptors]; 
	[request setPredicate:predicate];
	
	NSError *error; 
	NSFetchedResultsController * localRC = [[NSFetchedResultsController alloc] 
											initWithFetchRequest:request 
											managedObjectContext:self.managedObjectContext 
											sectionNameKeyPath:sectionGroupingName cacheName:cacheName]; 
	localRC.delegate=self;
	
	self.resultsController = localRC;
	[localRC release];
	
	if (![resultsController performFetch:&error]) { 
		NSLog(@"Error when performing fetch in OverviewTableViewController");
		NSLog(@"ERROR: %@", error);
	} 	
	// WHY?
	//[request release];
	
	[self.tableView reloadData];
}	

- (id)initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext*)context {
	
	self = [super initWithStyle:style];
	if (self != nil) {
		self.managedObjectContext = context;
		
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(doReloadData:)
		 name:@"transactionsUpdated"
		 object:nil];
		
	}
	return self;
}
-(void)doReloadData:(id)param {
	NSLog(@"From parent: Updating data in %@", self);	
	[self updateData];
}
// To be implemented by kids
-(void)updateData {}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	NSUInteger count = [[resultsController sections] count];
    if (count == 0) {
        count = 1;
    }
    return count;
	
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSArray *sections = [resultsController sections];
    NSUInteger count = 0;
    if ([sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    }
	return count;
}

// To be implemented by kids
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {return nil;}

- (void)dealloc {
	NSLog(@"Deallocing %@", self);
	
	// Remove as observer
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[managedObjectContext release];
	[resultsController release];	
	
	[super dealloc];
}

@end
