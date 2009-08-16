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
#import "CurrencyManager.h"
#import "FinanceAppDelegate.h"

@interface OverviewTableViewController (PrivateMethods)
- (void)clearDataCache;
@end


@implementation OverviewTableViewController

@synthesize overviewTableCell, cellCalculations;

#pragma mark -
#pragma mark Init and teardown
- (void)viewDidLoad {
	[super viewDidLoad];
			
	self.title = NSLocalizedString(@"Overview", @"Overview table transaction view");

	UIImageView * headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellOverviewHeader.png"]];
	self.tableView.tableHeaderView = headerView;
	[headerView release];
	
	UIImageView * footerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellOverviewFooter.png"]];
	self.tableView.tableFooterView = footerView;
	[footerView release];
	
	self.tableView.opaque = NO;
		
	// Only show last three months of data?
	// We don't know yet, depends on how many months there are...
	//onlyLast3Months = YES; 	
	onlyLast3Months = NO;

	/*
	 If the base currency is updated we have to delete our cache...
	 */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(baseCurrencyChanged) name:@"CurrencyManagerDidChangeBaseCurrency" object:nil];	

	/*
	 The update data call will be performed as needed if there are changes that haven't been caught...
	 FIXME: Does it still get new values?
	 */
	//[self updateData];
	
	[self setBadgeBalance];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	/*
	 Hide the top view that is just for making it look nice
	 FIXME: This makes it jump to the top whenever I go up a level to get to the overview controller!
	 */
//	[self.tableView setContentOffset:CGPointMake(0, 31.f) animated:NO];
//	
//	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
//	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
	
	NSLog(@"Reloading tableview on viewWillAppear in %@", self);
	[self.tableView reloadData];
	
}
- (void)viewDidUnload {
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
		
}
- (NSString*)cellCachePath {
	FinanceAppDelegate * app = (FinanceAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSString *archivePath = [app.applicationDocumentsDirectory stringByAppendingPathComponent:@"OverviewTableCache.archive"];
	return archivePath;
}
- (void) makeCachePersistent {
	// Save the cell calculations cache to get super speed up :D
	[NSKeyedArchiver archiveRootObject:self.cellCalculations
								toFile:[self cellCachePath]];
	NSLog(@"Saved cache!");
}

- (void)dealloc {
	[cellCalculations release];
	[overviewTableCell release];
	[super dealloc];
}

#pragma mark -
#pragma mark Populate data
// Initiates the fetch of results for the table view
- (void)updateData {
	@synchronized(self) {
		NSLog(@"Starting synchronized data load in %@", self);
		
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		
		NSLog(@"Updating data... Getting it from the datastore");
		
		// Sort descriptors
		NSSortDescriptor * sortByYearMonth = [[NSSortDescriptor alloc] initWithKey:@"yearMonth" ascending:NO];	
		NSArray * sortDescriptors = [NSArray arrayWithObjects:sortByYearMonth, nil];
		[sortByYearMonth release];
		
		// Perform the load
		[self loadDataWithSortDescriptors:sortDescriptors predicates:nil sectionNameKeyPath:@"yearMonth" cacheName:@"overviewTransactionCache"];	
		
		[pool release];
		NSLog(@"Ended synchronized data load in %@", self);
	}
}
- (NSFetchedResultsController*)resultsController {
	if (resultsController == nil) {
		NSLog(@"First time resultsController is accessed. Let's load it!");
		[self updateData];
	}
	return resultsController;
}
- (NSMutableDictionary*)cellCalculations {
	/* 
	 We load in the cached cell data as well
	 There are some conditions. First we check if it has already been loaded
	 If not we try to load it, and if that still doesn't result in any cache
	 then we create an empty cache dictionary
	 */
	if (cellCalculations == nil) {
		// Not loaded yet => load
		NSLog(@"Loading cell cache");
		self.cellCalculations = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cellCachePath]];
		if (cellCalculations == nil) { 
			// There didn't exist any cache. We create an empty dictionary
			NSLog(@"Cache was nil... has to be regenerated!");
			self.cellCalculations = [[NSMutableDictionary alloc] init];
		}
	}
	return cellCalculations;
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
	
	if ([self.cellCalculations objectForKey:@"numOfRows"] == nil) {
		NSUInteger iCount = [[self.resultsController sections] count];
		NSNumber * count = [NSNumber numberWithInt:iCount];
		[self.cellCalculations setObject:count forKey:@"numOfRows"];
		[self makeCachePersistent];
		NSLog(@"Had to calculate number of rows (%i)", iCount);
	}
	return [[self.cellCalculations objectForKey:@"numOfRows"] intValue];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	[self computeDataForIndexPath:indexPath];
	
	// Values to use
	NSDictionary * dict = [cellCalculations objectForKey:indexPath];
	
	// Get a cell:
	static NSString *CellIdentifier = @"OverviewCell";
	OverviewTableCell *cell = (OverviewTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"OverviewTableCell" owner:self options:nil]; 
		cell = self.overviewTableCell;
	}
	
	[cell updateCellWithDate:[dict objectForKey:@"date"] andAmount:[dict objectForKey:@"amount"]];
	
    return cell;
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// Values to use
	NSDictionary * dict = [cellCalculations objectForKey:indexPath];
	
    DetailTableViewController * detailController = [[DetailTableViewController alloc] initWithStyle:UITableViewStylePlain 
																						 andContext:managedObjectContext];
	detailController.delegate = self;
	detailController.yearMonthToDisplay = [dict objectForKey:@"yearMonth"];
	
	NSLog(@"Passing on yearMonth: %@", [dict objectForKey:@"yearMonth"]);
	
	// Passing along the filtering predicates so searches can be passed on
	detailController.filteringPredicate = self.filteringPredicate;

	[self.navigationController pushViewController:detailController animated:YES];
	[detailController release];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80;
}


#pragma mark
#pragma mark -
#pragma mark Cache and cache handling
- (void) computeDataForIndexPath:(NSIndexPath *)indexPath {
	if ([cellCalculations objectForKey:indexPath] == nil) {
				
		NSLog(@"Generating overview data for row: %i", indexPath.row);
		
		// Get info to put into cell:
		NSArray * sections = [self.resultsController sections];
		id <NSFetchedResultsSectionInfo> currenctSection = [sections objectAtIndex:indexPath.row];
		NSArray * _transactionsInSection = [currenctSection objects];
		NSArray * transactionsInSection = [_transactionsInSection filteredArrayUsingPredicate:self.filteringPredicate];
		
		Transaction * aTransaction = (Transaction*)[_transactionsInSection objectAtIndex:0];
		
		// Sum the amount
		double amount = [[Utilities toolbox] sumAmountForTransactionArray:transactionsInSection];
		
		NSDate * dateFromObject = aTransaction.date;
		// Do we have a valid date?
		int n = 0;
		/*
		 For some strange reason, some transactions don't have a date
		 Therefore we have to look through the transactions to see if we can find
		 a transaction with a date so that we can display the month name
		 */
		while (dateFromObject == nil) {
			n++;
			if (n >= [_transactionsInSection count]) {
				break;
			}
			
			Transaction * anotherTransaction = (Transaction*)[_transactionsInSection objectAtIndex:n];
			dateFromObject = anotherTransaction.date;
			
		}
		if (dateFromObject == nil) {
			// None of the transactions had a date, so we have to fake it...
			NSLog(@"ERROR: None of the transactions had a date! We had to fake one");
			dateFromObject = [NSDate date];
		}
		if (n!=0) {
			NSLog(@"Had to try %i times to get a date...",n);
		}
		
		NSNumber * numAmount = [NSNumber numberWithDouble:amount];
		NSString * calculatedAmount = [[CurrencyManager sharedManager] baseCurrencyDescriptionForAmount:numAmount withFraction:YES];
		NSString * yearMonth = aTransaction.yearMonth;
		
		NSArray * data = [NSArray arrayWithObjects:dateFromObject, calculatedAmount, numAmount, yearMonth, nil];
		NSArray * keys = [NSArray arrayWithObjects:@"date", @"amount", @"rawAmount", @"yearMonth", nil];
		NSDictionary * dict = [NSDictionary dictionaryWithObjects:data forKeys:keys];
		
		[cellCalculations setObject:dict forKey:indexPath];
		
		// Make the cache persistant so it is saved for later
		/*
		 FIXME: Save on exit or something, but can't figure out how to trigger that...
		 viewDidUnload is never triggered, and dealloc is not the place to do it because 
		 it isn't guaranteed to be called...
		 */
		
		[self makeCachePersistent];
	}
}
- (void) clearDataCache {
	[self.cellCalculations removeAllObjects];
}

- (void) baseCurrencyChanged {
	[self clearDataCache];
	[self.tableView reloadData];
}
- (void) setBadgeBalance {
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"KleioTransactionsBalanceBadge"] boolValue] == YES) {
		// We have to set the application badge to the current ballance
		NSInteger numberOfRows = [self tableView:self.tableView numberOfRowsInSection:0];
		
		double amount;
		
		for (int n = 0; n < numberOfRows; n++) {
			NSIndexPath * path = [NSIndexPath indexPathForRow:n inSection:0];
			[self computeDataForIndexPath:path];
			NSDictionary * dict = [self.cellCalculations objectForKey:path];
			NSNumber * rawAmount = [dict objectForKey:@"rawAmount"];
			amount += [rawAmount doubleValue];
			
		}
		
		NSInteger finalAmount = (NSInteger)amount;
		
		if ((finalAmount > 0) && (finalAmount < 10000)) {
			[[UIApplication sharedApplication] setApplicationIconBadgeNumber:finalAmount];
		} else {
			[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
		}
		
	}
}

#pragma mark -
#pragma mark NSFetchedResultsController delegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if ([[Utilities toolbox] isReloadingTableAllowed]) {
		[self.tableView reloadData];
		NSLog(@"Reloaded data in %@ because of controllerDidChangeContent:", self);
		[self setBadgeBalance];
	} else {
		NSLog(@"Reloaded data NOT ALLOWED in %@", self);
	}
}

@end

