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
#import "KleioSearchBar.h"
#import "CurrencyManager.h"
#import "CacheMasterSingleton.h"
#import "CacheMasterSingleton.h"

@interface DetailTableViewController (PrivateMethods)
- (NSDictionary*)dataForSection:(NSInteger)_section;
- (void)clearDataCache;
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
		
}
- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// Check if the filter was active
	if (filterActive) {
		// Reset
		filterActive = NO;
		if (filterString != nil) {[[KleioSearchBar searchBar] setSearchString:filterString];}
		[filterString release];
		[[KleioSearchBar searchBar] show];
	}
		
	[self updateIfWorthIt];
	
	UIImageView * paperTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DetailCellTop.png"]];
	self.tableView.tableHeaderView = paperTop;
	[paperTop release];
	
	UIImageView * paperBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DetailCellBottom.png"]];
	self.tableView.tableFooterView = paperBottom;
	[paperBottom release];
		
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

	[[CacheMasterSingleton sharedCacheMaster] setDetailTableDelegate:nil];
	
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
/*- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSLog(@"Asked to regenerate the index titles");
	
	NSInteger sectionCount = [[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections];
	
	NSMutableArray * titles = [[NSMutableArray alloc] initWithCapacity:sectionCount];
	
	for (NSInteger n = 0; n < sectionCount; n++) {
		NSDictionary * data = [[CacheMasterSingleton sharedCacheMaster] detailCache_dataForSection:n];
		NSArray * objectsInSection = [data objectForKey:@"transactions"];
		if ([objectsInSection count] > 0) {
			Transaction * trs = [objectsInSection objectAtIndex:0];
			[titles addObject:[NSString stringWithFormat:@"%i", [trs.day intValue]]];			
		}
	}
	NSArray * returnTitles = [NSArray arrayWithArray:titles];
	[titles release];
	
	return returnTitles;
}*/

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
	NSDictionary * data = [[CacheMasterSingleton sharedCacheMaster] detailCache_dataForSection:indexPath.section];
	
	Transaction *trs = (Transaction *)[[data objectForKey:@"transactions"] objectAtIndex:indexPath.row];
    
	static NSString *CellIdentifier = @"DetailCell";
    DetailContentTableCell * cell = (DetailContentTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[DetailContentTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}

	[cell configureCellForTransaction:trs];
				
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}
// section header view
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewForSection:section];
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	/*
	 Conditional height...
	 If there are elements, then it has a height. Otherwise make it 0
	 */
	NSDictionary * data = [[CacheMasterSingleton sharedCacheMaster] detailCache_dataForSection:section];
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
	NSDictionary * data = [[CacheMasterSingleton sharedCacheMaster] detailCache_dataForSection:_section];
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
		[bottom release];
	}
	return [footerViewCache objectForKey:section];
}
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	/*
	 Conditional height...
	 If there are elements, then it has a height. Otherwise make it 0
	 */
	NSDictionary * data = [[CacheMasterSingleton sharedCacheMaster] detailCache_dataForSection:section];
	NSInteger count = [[data objectForKey:@"transactions"] count];
	
	if (count != 0) {
		return 20;		
	} else {
		return 0;
	}}

// Chose a row to inspect. Show the detail view
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
	// Create new display that shows the transaction
	TransactionDisplay * infoDisplay =
		[[TransactionDisplay alloc] initWithNibName:@"TransactionDisplay" 
											 bundle:[NSBundle mainBundle]];
	
	NSDictionary * data = [[CacheMasterSingleton sharedCacheMaster] detailCache_dataForSection:indexPath.section];
	Transaction * theTransaction = (Transaction*)[[data objectForKey:@"transactions"] objectAtIndex:indexPath.row];
	
	// Give it the current transaction to speed things up
	infoDisplay.currentTransaction = theTransaction;

	// We are now going to show another page where the search bar is not required
	// Save search state:
	filterActive = [[KleioSearchBar searchBar] isVisible];
	filterString = [[[KleioSearchBar searchBar] searchString] retain];
	[[KleioSearchBar searchBar] hideButRetainState];
	
	// Show it
	[self.navigationController pushViewController:infoDisplay animated:YES];
	[infoDisplay release];
	
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return [[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:section];
}

// Override to support editing the table view.
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

		/*
		 We are doing a local delete
		 In which case I don't want to reload the whole table view
		 because we can just remove one row locally!
		 The overview table view on the other hand will be stale
		 because it has summaries of the transactions
		 */
		localDelete = YES;
		//[self.delegate clearDataCache];
		
		NSDictionary * data = [[CacheMasterSingleton sharedCacheMaster] detailCache_dataForSection:indexPath.section];
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
	}
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	if (localDelete) {
		switch(type) {
			case NSFetchedResultsChangeDelete:
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
				//[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
				//[self performSelector:@selector(updateDataIfWorthIt) withObject:nil afterDelay:0.3];

				break;
		}
	}
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	if (localDelete) {
		switch(type) {
				
			case NSFetchedResultsChangeDelete:				
				/*
				 All the cached data has been removed, so we can just as well reload the whole table
				 */
				[self clearDataCache];
				
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationBottom];
				//[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
				//[self performSelector:@selector(updateIfWorthIt) withObject:nil afterDelay:0.3];
				break;
		}
	}
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if (localDelete) {
		[self.tableView endUpdates];
	} else {
		[self updateIfWorthIt];
	}
	localDelete = NO;
}
//#pragma mark -
//#pragma mark NSFetchedResultsController delegate methods
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//	[self updateIfWorthIt];
//}

@end