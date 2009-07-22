//
//  ExpensesTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ExpensesTableViewController.h"
#import "Transaction.h"

#define OVERVIEW_SEGMENT_SELECTED 0
#define DETAIL_SEGMENT_SELECTED 1

@implementation ExpensesTableViewController

@synthesize resultsController;
@synthesize managedObjectContext;
@synthesize overviewTableCell;
@synthesize detailHeaderView, detailContentTableCell, detailFooterView;
@synthesize modeCtrl;

- (id)initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext*)context {
	self = [super initWithStyle:style];
	if (self != nil) {
		self.managedObjectContext = context;
		self.title = NSLocalizedString(@"Transactions", @"Transaction table view header");

		//Create a new segmented control
		UISegmentedControl * segCtrl = [[UISegmentedControl alloc] initWithItems:
			[NSArray arrayWithObjects:NSLocalizedString(@"Overview",@"Overview segment title in transaction table header"),
									  NSLocalizedString(@"Details", @"Detail segment title in the transaction table header"),nil]];
		segCtrl.segmentedControlStyle = UISegmentedControlStyleBar;
		segCtrl.selectedSegmentIndex = 0;
		//self.modeCtrl = segCtrl;
		
		// Listen to the events
		[segCtrl addObserver:self forKeyPath:@"selectedSegmentIndex" options:NSKeyValueObservingOptionNew context:nil];
		
		self.navigationItem.titleView = segCtrl;
		
		[segCtrl release];
	}
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"selectedSegmentIndex"]) {
		[[self tableView] reloadData];
	} 
}
		
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	// Load the expenses
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" 
											  inManagedObjectContext:self.managedObjectContext]; 
	[request setEntity:entity];
	
	NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc]
									initWithKey:@"kroner" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByDate, nil]; 
	[request setSortDescriptors:sortDescriptors]; 
	[sortDescriptors release]; 
	[sortByDate release]; 
	
	NSError *error; 
	NSFetchedResultsController * localRC = [[NSFetchedResultsController alloc] 
											initWithFetchRequest:request 
											managedObjectContext:self.managedObjectContext 
											sectionNameKeyPath:nil cacheName:@"transactionCache"]; 
	localRC.delegate=self;
	
	self.resultsController = localRC;
	[localRC release];
	
	if ([self.resultsController performFetch:&error]) { 
		NSLog(@"Error when performing fetch in messageTableViewController");
		//NSLog([error localizedDescription]);
	} 	
	[request release]; 
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

// TODO Implement releasing here!
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	Transaction *trs = (Transaction *)[resultsController objectAtIndexPath:indexPath];
    
	if ([self selectedSegment] == OVERVIEW_SEGMENT_SELECTED) {
		static NSString *CellIdentifier = @"OverviewCell";
		OverviewTableCell *cell = (OverviewTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"OverviewTableCell" owner:self options:nil]; 
			cell = self.overviewTableCell;
		}
		
		[cell setValuesWithTransaction:trs];

	    return cell;

	} else {
		
		static NSString *CellIdentifier = @"DetailCell";
	    DetailContentTableCell * cell = (DetailContentTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"DetailTableCell" owner:self options:nil]; 
			cell = self.detailContentTableCell;
		}
		
		cell.amount.text = [trs toString];
		cell.what.text = @"Sometime";
		
		[cell setBackgroundColorForCellNumber:indexPath.row];
		
	    return cell;
	}
		

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	[[NSBundle mainBundle] loadNibNamed:@"DetailHeaderAndFooter" owner:self options:nil]; 
	
	if ([self selectedSegment] == OVERVIEW_SEGMENT_SELECTED) {return 0;}
	
	return detailHeaderView;
	
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	[[NSBundle mainBundle] loadNibNamed:@"DetailHeaderAndFooter" owner:self options:nil]; 
	
	if ([self selectedSegment] == OVERVIEW_SEGMENT_SELECTED) {return 0;}	

	return detailFooterView;
}

-(NSInteger) selectedSegment {
	UISegmentedControl * buttonRack = (UISegmentedControl*) self.navigationItem.titleView;
	NSInteger selectedItem = buttonRack.selectedSegmentIndex;
	return selectedItem;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self selectedSegment] == OVERVIEW_SEGMENT_SELECTED) {
		return 40;
	} else {
		return 20;
	}
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
}

#pragma mark
#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

/*
 Assume self has a property 'tableView', as is the case for an instance of a UITableViewController
 subclass, and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
			 withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
			 withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
    UITableView *tableView = self.tableView;
	
    switch(type) {
			
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
			
			//        case NSFetchedResultsChangeUpdate:
			//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
			//					atIndexPath:indexPath];
			//            break;
			
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section]
					 withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}



- (void)dealloc {
	[managedObjectContext release];
	[resultsController release];

	[modeCtrl release];
	
	[overviewTableCell release];
	[detailHeaderView release];
	[detailContentTableCell release];
	[detailFooterView release];
	
	[super dealloc];
}


@end

