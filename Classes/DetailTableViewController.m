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

@implementation DetailTableViewController

@synthesize detailHeaderView, detailContentTableCell, detailFooterView;
@synthesize yearMonthToDisplay;
		
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	
	// Load the expenses
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" 
											  inManagedObjectContext:self.managedObjectContext]; 
	[request setEntity:entity];
	
	NSPredicate * monthPredicate = [NSPredicate predicateWithFormat:@"yearMonth = %@", yearMonthToDisplay];
	
	[request setPredicate:monthPredicate];
	
	NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc]
									initWithKey:@"day" ascending:NO];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByDate, nil]; 
	[request setSortDescriptors:sortDescriptors]; 
	[sortDescriptors release]; 
	[sortByDate release]; 
	
	NSError *error; 
	NSFetchedResultsController * localRC = [[NSFetchedResultsController alloc] 
											initWithFetchRequest:request 
											managedObjectContext:self.managedObjectContext 
											sectionNameKeyPath:@"day" cacheName:@"detailTransactionCache"]; 
	localRC.delegate=self;
	
	self.resultsController = localRC;
	[localRC release];
	
	if (![resultsController performFetch:&error]) { 
		NSLog(@"Error when performing fetch in OverviewTableViewController");
		NSLog(@"ERROR: %@", [error localizedDescription]);
	} 	
	[request release];
	
	[self.tableView reloadData];	
}

#pragma mark Table view methods

-(void)viewDidLoad {
	self.title = NSLocalizedString(@"Detail view", @"Detail table transaction view");
}

// To get the section shower on the side
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSArray * sections = resultsController.sections;
	NSInteger sectionCount = sections.count;
	
	NSMutableArray * titles = [[[NSMutableArray alloc] initWithCapacity:sectionCount] autorelease];
	
	NSLog(@"Returning an array of section names");
	
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
		NSLog(@"Creating a new detail cell...");
	}
		
	cell.amount.text = [trs toString];
	cell.what.text = trs.transactionDescription;
		
	[cell setBackgroundColorForCellNumber:indexPath.row];
		
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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



- (void)dealloc {
	[detailHeaderView release];
	[detailContentTableCell release];
	[detailFooterView release];
	
	[super dealloc];
}


@end

