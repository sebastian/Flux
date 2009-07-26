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

@implementation DetailTableViewController

@synthesize detailHeaderView, detailContentTableCell, detailFooterView;
@synthesize yearMonthToDisplay;

-(void)updateData {
	NSLog(@"From child: Updating data in %@", self);
	
	NSPredicate * monthPredicate = [NSPredicate predicateWithFormat:@"yearMonth = %@", yearMonthToDisplay];
	NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc]
									initWithKey:@"day" ascending:NO];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByDate, nil]; 
	
	[self loadDataWithSortDescriptors:sortDescriptors predicates:monthPredicate sectionNameKeyPath:@"day" cacheName:@"detailTransactionCache"];
	
	[sortDescriptors release]; 
	[sortByDate release];
	[monthPredicate release];
}

#pragma mark Table view methods

-(void)viewDidLoad {
	///////////////////////////////////////////
	// Get the calendar values
	NSLocale * userLocale = [NSLocale currentLocale];
	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setLocale:userLocale];

	// Month range
	NSRange range;
	range.length = 2;
	range.location = 4;
	
	NSInteger monthNum = [[yearMonthToDisplay substringWithRange:range] intValue] - 1;
	
	NSString * monthName = [[dateFormatter monthSymbols] objectAtIndex:monthNum];
	
	NSString * year = [yearMonthToDisplay substringToIndex:4];
	
	self.title = [NSString stringWithFormat:@"%@ %@", [monthName capitalizedString], year];
	
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	
	[self updateData];
	
}

// To get the section shower on the side
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSArray * sections = resultsController.sections;
	NSInteger sectionCount = sections.count;
	
	NSMutableArray * titles = [[[NSMutableArray alloc] initWithCapacity:sectionCount] autorelease];
	
	for (NSInteger n = 0; n < sectionCount; n++) {
		NSArray * objectsInSection = [[sections objectAtIndex:n] objects];
		Transaction * trs = [objectsInSection objectAtIndex:0];
		
		[titles addObject:[NSString stringWithFormat:@"%i", [trs.day intValue]]];
		
		[trs release];
	}
		
	return titles;
}

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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSArray * transactions = [[[resultsController sections] objectAtIndex:section] objects];
	Transaction * aTransaction = (Transaction*) [transactions objectAtIndex:0];
		
	// Calculate the amount
	int iKroner = [(NSNumber*)[transactions valueForKeyPath:@"@sum.kroner"] intValue];
	int iOre = [(NSNumber*)[transactions valueForKeyPath:@"@sum.ore"] intValue];
	
	double amount = iKroner + ((double)iOre/100);
	NSNumber * numAmount = [NSNumber numberWithDouble:amount];
	
	// Get a cell
	[[NSBundle mainBundle] loadNibNamed:@"DetailHeaderAndFooter" owner:self options:nil]; 
	
	// TODO: Localize the date format display
	detailHeaderView.monthYear.text = self.title;
	detailHeaderView.date.text = [aTransaction.day stringValue];
	detailHeaderView.amount.text = [aTransaction numberToMoney:numAmount];
	
	return detailHeaderView;
	
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	[[NSBundle mainBundle] loadNibNamed:@"DetailHeaderAndFooter" owner:self options:nil]; 
	
	return detailFooterView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	TransactionDisplay * infoDisplay =
		[[TransactionDisplay alloc] initWithNibName:@"TransactionDisplay" 
											 bundle:[NSBundle mainBundle]];
	
	Transaction * theTransaction = (Transaction*)[resultsController objectAtIndexPath:indexPath];
	
	infoDisplay.currentTransaction = theTransaction;
	
	[self.navigationController pushViewController:infoDisplay animated:YES];
	
	// I thinkg the navigation controller retains it, so I can release it here
	[infoDisplay release];
	
}


- (void)dealloc {
	[detailHeaderView release];
	[detailContentTableCell release];
	[detailFooterView release];
	
	[super dealloc];
}


@end

