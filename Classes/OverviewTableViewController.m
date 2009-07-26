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

-(void)updateData {	
	NSSortDescriptor * sortByYearMonth = [[NSSortDescriptor alloc]
										  initWithKey:@"yearMonth" ascending:NO];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByYearMonth, nil]; 
	
	[self loadDataWithSortDescriptors:sortDescriptors predicates:nil sectionNameKeyPath:@"yearMonth" cacheName:@"overviewTransactionCache"];
	
	[sortDescriptors release]; 
	[sortByYearMonth release];
}


-(void)viewDidLoad {
	self.title = NSLocalizedString(@"Overview", @"Overview table transaction view");
	[self updateData];
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
	int iKroner;
	@try {
		iKroner = [(NSNumber*)[transactionsInSection valueForKeyPath:@"@sum.kroner"] intValue];
	}
	@catch (NSException * e) {
		NSLog(@"Error when summing kroner for row %i", indexPath.row);
		NSLog(@"ERROR: %@", e);
		NSLog(@"transactions: %@", transactionsInSection);
		iKroner = 0;
	}
	
	int iOre;
	@try {
		iOre = [(NSNumber*)[transactionsInSection valueForKeyPath:@"@sum.ore"] intValue];
	}
	@catch (NSException * e) {
		NSLog(@"Error when summing ore for row %i", indexPath.row);
		NSLog(@"ERROR: %@", e);
		NSLog(@"transactions: %@", transactionsInSection);
		iOre = 0;
	}

	double amount = iKroner + ((double)iOre/100);
	
	NSDate * dateFromObject = aTransaction.date;
	NSNumber * calculatedAmount = [NSNumber numberWithDouble:amount];
	
	[cell updateCellWithDate:dateFromObject andAmount:[aTransaction numberToMoney:calculatedAmount]];
	
    return cell;
		
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    DetailTableViewController * detailController = 
		[[DetailTableViewController alloc] initWithStyle:UITableViewStylePlain 
											  andContext:managedObjectContext];

	/*
	 TODO:
	 Goal:		I have to pass inn the yearMonth value to display
	 How:		Right now I am looking at one of the objects in the current
				section and subtrackting the value from it. Not very elegant...
				A lot of unneeded object traversal
	 Improve:	Could be improved by building up a dictionary with section -> yearMonth values
	 */
	NSArray * sections = [resultsController sections];
	id <NSFetchedResultsSectionInfo> currenctSection = [sections objectAtIndex:indexPath.row];
	NSArray * transactionsInSection = [currenctSection objects];	
	Transaction * aTransaction = (Transaction*)[transactionsInSection objectAtIndex:0];
	
	detailController.yearMonthToDisplay = aTransaction.yearMonth;
	
	[self.navigationController pushViewController:detailController animated:YES];
	[detailController release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (void)dealloc {
	[overviewTableCell release];
	[super dealloc];
}

@end

