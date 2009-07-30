//
//  ExpensesTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "DetailTableViewController.h"
#import "Transaction.h"
#import "TransactionDisplay.h"
#import "Utilities.h"

@implementation DetailTableViewController

@synthesize detailHeaderView, detailContentTableCell, detailFooterView;
@synthesize yearMonthToDisplay;

#pragma mark -
#pragma mark Init and teardown
-(void)viewDidLoad {

	// Get the calendar values
	NSLocale * userLocale = [NSLocale currentLocale];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:userLocale];
	
	// Month range
	NSRange range;
	range.length = 2;
	range.location = 4;
	
	@try {
		// Set the title to the month and year that is viewed
		NSInteger monthNum = [[yearMonthToDisplay substringWithRange:range] intValue] - 1;
		NSString * monthName = [[dateFormatter monthSymbols] objectAtIndex:monthNum];
		NSString * year = [yearMonthToDisplay substringToIndex:4];
		self.title = [NSString stringWithFormat:@"%@ %@", [monthName capitalizedString], year];
	}
	@catch (NSException * e) {
		NSLog(@"Error setting the title of the detail view table view...");
		self.title = NSLocalizedString(@"ERROR", @"Some error...");
	}
	
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	
	[dateFormatter release];
	[self updateData];
}
-(void)dealloc {
	[detailHeaderView release];
	[detailContentTableCell release];
	[detailFooterView release];
	[yearMonthToDisplay release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Populate data
-(void)updateData {
	
	// Sort descriptors
	NSSortDescriptor *sortByDay = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
	NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByDay, sortByDate, nil]; 
	[sortByDate release];
	[sortByDay release];
	
	// Predicate(s)
	NSPredicate * monthPredicate = [NSPredicate predicateWithFormat:@"yearMonth = %@", yearMonthToDisplay];
	
	// Perform loading of data
	[self loadDataWithSortDescriptors:sortDescriptors predicates:monthPredicate sectionNameKeyPath:@"day" cacheName:@"detailTransactionCache"];
	
	[sortDescriptors release]; 

}

#pragma mark Table view methods
// To get the section shower on the side
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSArray * sections = resultsController.sections;
	NSInteger sectionCount = sections.count;
	
	NSMutableArray * titles = [[[NSMutableArray alloc] initWithCapacity:sectionCount] autorelease];
	
	for (NSInteger n = 0; n < sectionCount; n++) {
		NSArray * objectsInSection = [[sections objectAtIndex:n] objects];
		Transaction * trs = [objectsInSection objectAtIndex:0];
		
		[titles addObject:[NSString stringWithFormat:@"%i", [trs.day intValue]]];
	}
		
	return titles;
}

// Content cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	Transaction *trs = (Transaction *)[resultsController objectAtIndexPath:indexPath];
    
	static NSString *CellIdentifier = @"DetailCell";
    DetailContentTableCell * cell = (DetailContentTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"DetailTableCell" owner:self options:nil]; 
		cell = self.detailContentTableCell;
	}
		
	cell.amount.text = [trs toString];
	cell.what.text = trs.transactionDescription;
		
	[cell setBackgroundColorForCellNumber:indexPath.row];
		
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 30;
}
// Header view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	NSArray * transactions = [[[resultsController sections] objectAtIndex:section] objects];
	Transaction * aTransaction = (Transaction*) [transactions objectAtIndex:0];
		
	// Calculate the amount
	double amount = [Utilities sumAmountForTransactionArray:transactions];
	NSNumber * numAmount = [NSNumber numberWithDouble:amount];
	
	// Get a cell
	[[NSBundle mainBundle] loadNibNamed:@"DetailHeaderAndFooter" owner:self options:nil]; 
	
	// TODO: Localize the date format display
	detailHeaderView.monthYear.text = self.title;
	detailHeaderView.date.text = [aTransaction.day stringValue];
	detailHeaderView.amount.text = [aTransaction numberToMoney:numAmount];
	
	return detailHeaderView;
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30;
}
// Footer view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	[[NSBundle mainBundle] loadNibNamed:@"DetailHeaderAndFooter" owner:self options:nil]; 
	return detailFooterView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 20;
}

// Chose a row to inspect. Show the detail view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	TransactionDisplay * infoDisplay =
		[[TransactionDisplay alloc] initWithNibName:@"TransactionDisplay" 
											 bundle:[NSBundle mainBundle]];
	
	Transaction * theTransaction = (Transaction*)[resultsController objectAtIndexPath:indexPath];
	
	infoDisplay.currentTransaction = theTransaction;
	
	[self.navigationController pushViewController:infoDisplay animated:YES];
	
	[infoDisplay release];
	
}

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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		NSManagedObjectContext *context = [resultsController managedObjectContext];
		[context deleteObject:[resultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error;
		if (![context save:&error]) {
			// Handle the error...
		}
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}


@end

