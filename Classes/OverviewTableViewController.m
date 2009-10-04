//
//  ExpensesTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "DetailTableViewController.h"
#import "OverviewTableCell.h"
#import "OverviewTableViewController.h"
#import "Transaction.h"
#import "Utilities.h"
#import "CurrencyManager.h"
#import "FinanceAppDelegate.h"
#import "CacheMasterSingleton.h"



@implementation OverviewTableViewController

@synthesize overviewTableCell;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

/*
 FIXME: potentially a problem!
 What happens if the overview controller is unloaded because of low memory 
 while the detail view is in view. If the user then adds a transaction it might
 never be merged into the context, and hence not show in the table!
 Merging should therefore be done outside of any of the table view controllers
 to avoid having to wait for either to be loaded
 */
- (void)objectContextUpdated:(NSNotification *)notification {
	[self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];	
}

// Initiates the fetch of results for the table view
- (void)updateData {
	@synchronized(self) {
		
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		
		// Sort descriptors
		NSSortDescriptor * sortByYearMonth = [[NSSortDescriptor alloc] initWithKey:@"yearMonth" ascending:NO];	
		NSArray * sortDescriptors = [NSArray arrayWithObjects:sortByYearMonth, nil];
		[sortByYearMonth release];
		
		// Perform the load
		[self loadDataWithSortDescriptors:sortDescriptors predicates:nil sectionNameKeyPath:@"yearMonth" cacheName:@"overviewTransactionCache"];	
		
		[pool release];
	}
}

- (void) delayedDataLoad:(OverviewTableViewController*)controller {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	sleep(2);
	
	[controller updateData];
	
	[pool release];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) init {
	if (self = [super init]) {
		self.managedObjectContext = [[Utilities toolbox] createObjectContext];
		
		TTLOG(@"Registering for managedObjectContext changes in %@", self);
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(objectContextUpdated:)
		 name:NSManagedObjectContextDidSaveNotification
		 object:nil];
		
		/*
		 Try delaying this to speed up loading
		 */
		//[self performSelectorInBackground:@selector(delayedDataLoad:) withObject:self];
		[self updateData];
	}
	return self;
}

- (void)dealloc {
	// Remove as observer
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	TT_RELEASE_SAFELY(overviewTableCell);
	
	[[CacheMasterSingleton sharedCacheMaster] setOverviewTableDelegate:nil];
	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Overview", @"Overview table transaction view");
	self.tabBarItem.title = NSLocalizedString(@"List", nil);
	
	UIImageView * headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellOverviewHeader.png"]];
	self.tableView.tableHeaderView = headerView;
	[headerView release];
	
	UIImageView * footerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellOverviewFooter.png"]];
	self.tableView.tableFooterView = footerView;
	[footerView release];
	
	self.tableView.opaque = NO;
		
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self updateIfWorthIt];
	
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UITableView

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
	 If there are no rows, then we add a row that sais that there is no content available.
	 Otherwise we return the actual amount of rows
	 */
	if ([[CacheMasterSingleton sharedCacheMaster] overviewCache_numberOfRows] == 0) {return 1;}
	return [[CacheMasterSingleton sharedCacheMaster] overviewCache_numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	/*
	 If there are no rows, then we just return a dummy row that isn't cached
	 that tells the user that there aren't actually any data available at all.
	 Otherwise we return a real row
	 */
	if ([[CacheMasterSingleton sharedCacheMaster] overviewCache_numberOfRows] == 0) {
		UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
		[cell setUserInteractionEnabled:NO];
		
		// Create a text label
		UILabel * label = [[UILabel alloc] init];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor grayColor];
		label.font = [UIFont systemFontOfSize:18.f];
		label.text = NSLocalizedString(@"No transactions added", nil);
		[label sizeToFit];
		label.top = cell.height - label.height;
		label.left = (cell.width - label.width) / 2;
		[cell addSubview:label];
		[label release];
		
		return [cell autorelease];
	}
	
	
	NSDictionary * dict = [[CacheMasterSingleton sharedCacheMaster] overviewCache_forRow:indexPath.row];
	
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary * dict = [[CacheMasterSingleton sharedCacheMaster] overviewCache_forRow:indexPath.row];
	
	DetailTableViewController * detailController = [[DetailTableViewController alloc] initWithStyle:UITableViewStylePlain 
																																											 andContext:self.managedObjectContext];
	detailController.delegate = self;
	detailController.yearMonthToDisplay = [dict objectForKey:@"yearMonth"];
	
	// Passing along the filtering predicates so searches can be passed on
	detailController.filteringPredicate = self.filteringPredicate;
	
	[self.navigationController pushViewController:detailController animated:YES];
	[detailController release];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	CoreData

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self updateIfWorthIt];
}

@end

