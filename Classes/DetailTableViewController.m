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
#import "FilterField.h"
#import "CurrencyManager.h"

@interface DetailTableViewController (PrivateMethods)
- (NSDictionary*)dataForSection:(NSInteger)_section;
- (void)clearDataCache;
- (void)clearDataCacheForSection:(NSInteger)section;
@end



@implementation DetailTableViewController

@synthesize detailHeaderView, detailContentTableCell, detailFooterView;
@synthesize yearMonthToDisplay;
@synthesize transactionsDataCache, headerViewCache, footerViewCache;
@synthesize delegate;

#pragma mark -
#pragma mark Init and teardown
- (void) viewDidLoad {
	[super viewDidLoad];
		
	// Set local delete to a logic state;
	localDelete = NO;
	
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
	
	[dateFormatter release];
	
	[self updateData];
	
	UIImageView * paperTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DetailCellTop.png"]];
	self.tableView.tableHeaderView = paperTop;
	[paperTop release];
	
	UIImageView * paperBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DetailCellBottom.png"]];
	self.tableView.tableFooterView = paperBottom;
	[paperBottom release];
		
}
- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// Check if the filter was active
	if (filterActive) {
		// Reset
		filterActive = NO;
		if (filterString != nil) {[[FilterField sharedFilterBar] setSearchString:filterString];}
		[filterString release];
		[[FilterField sharedFilterBar] show];
	}
	
	/*
	 Hide the top view that is just for making it look nice
	 */
	[self.tableView setContentOffset:CGPointMake(0, 40.f) animated:NO];
	
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
	
	
}


- (void) dealloc {
	[transactionsDataCache release];
	[detailContentTableCell release];
	[detailFooterView release];
	[yearMonthToDisplay release];
	[headerViewCache release];
	[detailHeaderView release];
	[footerViewCache release];

	self.delegate = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Populate data
-(void) updateData {
	
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
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSLog(@"Asked to regenerate the index titles");
	
	NSArray * sections = resultsController.sections;
	NSInteger sectionCount = sections.count;
	
	NSMutableArray * titles = [[[NSMutableArray alloc] initWithCapacity:sectionCount] autorelease];
	
	for (NSInteger n = 0; n < sectionCount; n++) {
		NSDictionary * data = [self dataForSection:n];
		NSArray * objectsInSection = [data objectForKey:@"transactions"];
		if ([objectsInSection count] > 0) {
			Transaction * trs = [objectsInSection objectAtIndex:0];
			[titles addObject:[NSString stringWithFormat:@"%i", [trs.day intValue]]];			
		}
	}
		
	return titles;
}

/*
 Optimize by only ever calculating the data once!
 */
- (NSDictionary*) dataForSection:(NSInteger)_section {
	
	NSString * section = [NSString stringWithFormat:@"%i", _section];
	
	// Init if it doesn't exist
	if (self.transactionsDataCache == nil) {
		self.transactionsDataCache = [NSMutableDictionary dictionary];
	}
	
	if ([transactionsDataCache objectForKey:section] == nil) {
			
		NSLog(@"Generating data for section %i", _section);
		
		// General data
		NSArray * _transactions = [[[resultsController sections] objectAtIndex:_section] objects];
		NSArray * transactions = [_transactions filteredArrayUsingPredicate:self.filteringPredicate];
		
		// Data for header
		Transaction * aTransaction = (Transaction*) [_transactions objectAtIndex:0];
		
		// Calculate the amount
		double dAmount = [[Utilities toolbox] sumAmountForTransactionArray:transactions];
		NSNumber * numAmount = [NSNumber numberWithDouble:dAmount];
			
		// TODO: Localize the date format display
		NSString * date = [aTransaction.day stringValue];
		//NSString * amount = [aTransaction numberToMoney:numAmount];
		NSString * amount = [[CurrencyManager sharedManager] baseCurrencyDescriptionForAmount:numAmount withFraction:YES];
			
		// Data that has been worked on
		NSArray * objects = [NSArray arrayWithObjects:transactions, date, amount,nil];
		NSArray * keys = [NSArray arrayWithObjects:@"transactions", @"date", @"amount", nil];
		NSDictionary * data = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
			
		// Insert into dictionary
		[transactionsDataCache setObject:data forKey:section];

	} 
		
	return [transactionsDataCache objectForKey:section];
		
}
- (void)clearDataCache {
	[self.transactionsDataCache removeAllObjects];
	[self.headerViewCache removeAllObjects];
	[self.footerViewCache removeAllObjects];
}
- (void)clearDataCacheForSection:(NSInteger)_section {
	NSString * section = [NSString stringWithFormat:@"%i", _section];

	// Remove data for all sections
	[self.transactionsDataCache removeObjectForKey:section];
	[self.headerViewCache removeObjectForKey:section];

	// It is fast to regenerate, and clearing it might fix some bugs...
	[self.footerViewCache removeAllObjects];
}

// Content cell
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
		
	// Access the object from the filtered array
	NSDictionary * data = [self dataForSection:indexPath.section];
	Transaction *trs = (Transaction *)[[data objectForKey:@"transactions"] objectAtIndex:indexPath.row];
    
	static NSString *CellIdentifier = @"DetailCell";
    DetailContentTableCell * cell = (DetailContentTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"DetailTableCell" owner:self options:nil]; 
		cell = self.detailContentTableCell;
	}

	[cell configureCellForTransaction:trs];
				
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}
// section header view
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)_section {
	/*
	 If there are no elements in the section, then we don't want to display it
	 */
	NSDictionary * data = [self dataForSection:_section];
	NSInteger count = [[data objectForKey:@"transactions"] count];
	if (count == 0) {return nil;}
	
	
	NSString * section = [NSString stringWithFormat:@"%i", _section];
	
	if (self.headerViewCache == nil) { self.headerViewCache = [[NSMutableDictionary alloc] init];}
	
	if ([headerViewCache objectForKey:section] == nil) {

		[[NSBundle mainBundle] loadNibNamed:@"DetailHeaderAndFooter" owner:self options:nil]; 
		
//		// Get data for view
//		NSDictionary * data = [self dataForSection:_section];
		
		// TODO: Localize the date format display
		detailHeaderView.monthYear.text = self.title;
		detailHeaderView.date.text = [data objectForKey:@"date"];
		detailHeaderView.amount.text = [data objectForKey:@"amount"];
		
		// Store view
		[headerViewCache setObject:detailHeaderView forKey:section];
		
	}
	
	return [headerViewCache objectForKey:section];
	
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	/*
	 Conditional height...
	 If there are elements, then it has a height. Otherwise make it 0
	 */
	NSDictionary * data = [self dataForSection:section];
	NSInteger count = [[data objectForKey:@"transactions"] count];

	if (count != 0) {
		return 30;		
	} else {
		return 0;
	}
	
}
// Footer view
- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)_section {
	/*
	 If there are no elements in the section, then we don't want to display it
	 */
	NSDictionary * data = [self dataForSection:_section];
	NSInteger count = [[data objectForKey:@"transactions"] count];
	if (count == 0) {
		return nil;
	}
	
	NSString * section = [NSString stringWithFormat:@"%i", _section];	
	if (self.footerViewCache == nil) { self.footerViewCache = [[NSMutableDictionary alloc] init];}
	
	if ([footerViewCache objectForKey:section] == nil) {
		UIImageView * bottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DetailCellFooter.png"]];
		// Store view
		[footerViewCache setObject:bottom forKey:section];
	}
	return [footerViewCache objectForKey:section];
}
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	/*
	 Conditional height...
	 If there are elements, then it has a height. Otherwise make it 0
	 */
	NSDictionary * data = [self dataForSection:section];
	NSInteger count = [[data objectForKey:@"transactions"] count];
	
	if (count != 0) {
		return 20;		
	} else {
		return 0;
	}}

// Chose a row to inspect. Show the detail view
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// We are now going to show another page where the search bar is not required
	// Save search state:
	filterActive = [[FilterField sharedFilterBar] isVisible];
	filterString = [[[FilterField sharedFilterBar] searchString] retain];
	[[FilterField sharedFilterBar] hide];
	
	// Create new display that shows the transaction
	TransactionDisplay * infoDisplay =
		[[TransactionDisplay alloc] initWithNibName:@"TransactionDisplay" 
											 bundle:[NSBundle mainBundle]];
	
	NSDictionary * data = [self dataForSection:indexPath.section];
	Transaction * theTransaction = (Transaction*)[[data objectForKey:@"transactions"] objectAtIndex:indexPath.row];
	
	// Give it the current transaction to speed things up
	infoDisplay.currentTransaction = theTransaction;
	
	// Show it
	[self.navigationController pushViewController:infoDisplay animated:YES];
	[infoDisplay release];
	
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	NSUInteger count = [[resultsController sections] count];
    return count;
	
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSDictionary * data = [self dataForSection:section];
	NSInteger count = [[data objectForKey:@"transactions"] count];
	return count;
}

// Override to support editing the table view.
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

		/*
		 We are doing a local delete
		 In which case I don't want to reload the whole table view
		 because we can just remove one row locally!
		 */
		localDelete = YES;
		[self.delegate clearDataCache];
		[[self.delegate tableView] reloadData];
		
		NSDictionary * data = [self dataForSection:indexPath.section];
		Transaction *trs = (Transaction *)[[data objectForKey:@"transactions"] objectAtIndex:indexPath.row];
		
		// Delete cache for section
		[self clearDataCacheForSection:indexPath.section];
		
		// Delete the managed object for the given index path
		[self.managedObjectContext deleteObject:trs];

		// Save changes
		[[Utilities toolbox] save:self.managedObjectContext];
		
	}   
}


#pragma mark
#pragma mark -
#pragma mark Fetched results controller delegate methods...
/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if (localDelete) {
		[self.tableView beginUpdates];
	} else {
		[super controllerWillChangeContent:controller];
	}
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	if (localDelete) {
		switch(type) {
			case NSFetchedResultsChangeDelete:
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
				[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
				
				break;
		}
	} else {
		[super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
	}
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	if (localDelete) {
		switch(type) {
				
			case NSFetchedResultsChangeDelete:
				/*
				 I am removing a section, so the section caches are all wrong
				 because the indexes aren't the same anymore!
				 */
				[self clearDataCache];
				
				/*
				 All the cached data has been removed, so we can just as well reload the whole table
				 */
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationBottom];
				[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
				break;
		}
	} else {
		[super controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
	}
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if (localDelete) {
		[self.tableView endUpdates];
	} else {
		[super controllerDidChangeContent:controller];
	}
	localDelete = NO;
}

@end