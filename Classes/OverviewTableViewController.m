//
//  ExpensesTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "OverviewTableViewController.h"
#import "Transaction.h"
#import "DetailTableViewController.h"

@implementation OverviewTableViewController

@synthesize overviewTableCell;

- (id)initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext*)context {
	self = [super initWithStyle:style andContext:context];
	if (self != nil) {
	}
	return self;
}

-(void)viewDidLoad {
	self.title = NSLocalizedString(@"Overview", @"Overview table transaction view");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
		
	// Load the expenses
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" 
											  inManagedObjectContext:self.managedObjectContext]; 
	[request setEntity:entity];
	
	NSSortDescriptor * sortByYearMonth = [[NSSortDescriptor alloc]
									initWithKey:@"yearMonth" ascending:NO];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByYearMonth, nil]; 
	[request setSortDescriptors:sortDescriptors]; 
	[sortDescriptors release]; 
	[sortByYearMonth release]; 
	
	NSError *error; 
	NSFetchedResultsController * localRC = [[NSFetchedResultsController alloc] 
											initWithFetchRequest:request 
											managedObjectContext:self.managedObjectContext 
											sectionNameKeyPath:@"yearMonth" cacheName:@"overviewTransactionCache"]; 
	localRC.delegate=self;
	
	self.resultsController = localRC;
	[localRC release];
	
	if (![resultsController performFetch:&error]) { 
		NSLog(@"Error when performing fetch in OverviewTableViewController");
		NSLog(@"ERROR: %@", [error localizedDescription]);
		NSLog(@"ERROR: %@", error);
	} 	
	[request release];
	
	[self.tableView reloadData];

}

#pragma mark Table view methods

/*
 We always return that there is 1 section.
 In the table there will be displayed one row per each section
 in the resultsController...
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger count = [[resultsController sections] count];
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	// Get a cell:
	static NSString *CellIdentifier = @"OverviewCell";
	OverviewTableCell *cell = (OverviewTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"OverviewTableCell" owner:self options:nil]; 
		cell = self.overviewTableCell;
	}
	
	// Get info to put into cell:
	NSArray * sections = [resultsController sections];
	id <NSFetchedResultsSectionInfo> currenctSection = [sections objectAtIndex:indexPath.row];
	NSArray * transactionsInSection = [currenctSection objects];

	Transaction * aTransaction = (Transaction*)[transactionsInSection objectAtIndex:0];
	
	// Sum the amount
	int iKroner = [(NSNumber*)[transactionsInSection valueForKeyPath:@"@sum.kroner"] intValue];
	int iOre = [(NSNumber*)[transactionsInSection valueForKeyPath:@"@sum.ore"] intValue];

	double amount = iKroner + ((double)iOre/100);
	
	NSDate * dateFromObject = aTransaction.date;
	NSNumber * calculatedAmount = [NSNumber numberWithDouble:amount];
	
	[cell updateCellWithDate:dateFromObject andAmount:[aTransaction numberToMoney:calculatedAmount]];
	
    return cell;
		
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    DetailTableViewController * detailController = 
	[[[DetailTableViewController alloc] initWithStyle:UITableViewStylePlain 
										   andContext:self.managedObjectContext] autorelease];

	
	// Must be able to cache this somehow... Dictionary? To save this extra traversal...
	NSArray * sections = [resultsController sections];
	id <NSFetchedResultsSectionInfo> currenctSection = [sections objectAtIndex:indexPath.row];
	NSArray * transactionsInSection = [currenctSection objects];	
	Transaction * aTransaction = (Transaction*)[transactionsInSection objectAtIndex:0];
	
	detailController.yearMonthToDisplay = aTransaction.yearMonth;
	
	[self.navigationController pushViewController:detailController animated:YES];
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (void)dealloc {
	[overviewTableCell release];
	[super dealloc];
}

@end

