//
//  ExpensesTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "OverviewTableCell.h"
#import "OverviewTableViewController.h"
#import "Transaction.h"
#import "DetailTableViewController.h"
#import "Utilities.h"

@implementation OverviewTableViewController

@synthesize overviewTableCell;

#pragma mark -
#pragma mark Init and teardown
-(void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Overview", @"Overview table transaction view");

	UIImageView * headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OverviewCellTopp.png"]];
	self.tableView.tableHeaderView = headerView;
	[headerView release];
	
	UIImageView * footerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OverviewCellBunn.png"]];
	self.tableView.tableFooterView = footerView;
	[footerView release];
	
	self.tableView.opaque = NO;
	
//	UIImageView * backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OverviewBackground.png"]];
//	[self.tableView addSubview:backgroundView];
//	[self.view sendSubviewToBack:backgroundView];
//	[backgroundView release];
	
	// Only show last three months of data?
	// We don't know yet, depends on how many months there are...
	onlyLast3Months = YES; 	

	[self updateData];
}
- (void)dealloc {
	[overviewTableCell release];
	[super dealloc];
}

#pragma mark -
#pragma mark Populate data
// Initiates the fetch of results for the table view
- (void)updateData {
	// Sort descriptors
	NSSortDescriptor * sortByYearMonth = [[NSSortDescriptor alloc] initWithKey:@"yearMonth" ascending:NO];	
	NSArray * sortDescriptors = [NSArray arrayWithObjects:sortByYearMonth, nil];
	[sortByYearMonth release];
	
	// Predicates
	const NSInteger numberOfMonthsToSubtract = 3;
	NSCalendar * currentCalendar = [NSCalendar currentCalendar];
	NSDateComponents * components = [currentCalendar components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSinceNow:-(60 * 60 * 24 * 31 * numberOfMonthsToSubtract)]];
	
	NSString * yearMonthValue;
	if (components.month < 10) {
		yearMonthValue = [NSString stringWithFormat:@"%4i0%i", components.year, components.month];
	} else {
		yearMonthValue = [NSString stringWithFormat:@"%4i%i", components.year, components.month];
	}
	NSPredicate * onlyLastNMonths = [NSPredicate predicateWithFormat:@"yearMonth > %@", yearMonthValue];
	
	// Only use the predicate if we are asked to only display the last N months
	if (!onlyLast3Months) {onlyLastNMonths = nil;}
	
	// Perform the load
	[self loadDataWithSortDescriptors:sortDescriptors predicates:onlyLastNMonths sectionNameKeyPath:@"yearMonth" cacheName:@"overviewTransactionCache"];	
}


#pragma mark -
#pragma mark Table view methods
/*
 We always return that there is 1 section.
 In the table there will be displayed one row per each section
 in the resultsController...
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
/*
 Each section is made into one row in the table view
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	/*
	 Depending on if I only show the last three rows or not
	 I selectively fake a result here
	 */
	NSUInteger count = [[resultsController sections] count];
	if (onlyLast3Months && (count < 3)) {
		onlyLast3Months = NO;
		return count;
	} else if (onlyLast3Months) {
		numOfSections = count;
		return count + 1;
	} else {
		return count;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Get a cell:
	static NSString *CellIdentifier = @"OverviewCell";
	OverviewTableCell *cell = (OverviewTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"OverviewTableCell" owner:self options:nil]; 
		cell = self.overviewTableCell;
	}

	if (onlyLast3Months && indexPath.row == numOfSections) {
		// Remove old values
		cell.amount.text = @"";
		cell.year.text = @"";
		cell.month.text = @"";
		cell.loadHistory.text = NSLocalizedString(@"Load history", @"Load history table cell title");
		return cell;
	} else {
		cell.loadHistory.text = @"";
	}
	
	// Get info to put into cell:
	NSArray * sections = [resultsController sections];
	id <NSFetchedResultsSectionInfo> currenctSection = [sections objectAtIndex:indexPath.row];
	NSArray * _transactionsInSection = [currenctSection objects];
	NSArray * transactionsInSection = [_transactionsInSection filteredArrayUsingPredicate:self.filteringPredicate];

	Transaction * aTransaction = (Transaction*)[_transactionsInSection objectAtIndex:0];
	
	// Sum the amount
	double amount = [[Utilities toolbox] sumAmountForTransactionArray:transactionsInSection];
	
	NSDate * dateFromObject = aTransaction.date;
	NSNumber * calculatedAmount = [NSNumber numberWithDouble:amount];
	
	[cell updateCellWithDate:dateFromObject andAmount:[aTransaction numberToMoney:calculatedAmount]];
	
    return cell;
		
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	/*
	 Did the user click the load more data cell?
	 */
	if (onlyLast3Months && indexPath.row == numOfSections) {
		onlyLast3Months = NO;
		[self updateData];
		[self.tableView reloadData];
		return;
	}

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
	
    DetailTableViewController * detailController = [[DetailTableViewController alloc] initWithStyle:UITableViewStylePlain 
																						 andContext:managedObjectContext];

	// Needed to get the right search results and to display the right header
	detailController.yearMonthToDisplay = aTransaction.yearMonth;
	
	// Passing along the filtering predicates so searches can be passed on
	detailController.filteringPredicate = self.filteringPredicate;
	
	[self.navigationController pushViewController:detailController animated:YES];
	[detailController release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

@end

