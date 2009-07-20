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

@implementation ExpensesTableViewController

@synthesize resultsController;
@synthesize managedObjectContext;
@synthesize tableCell;

-(id) initWithNibName:(NSString*)nibName bundle:(NSBundle*)bundle {
	self = [super initWithNibName:nibName bundle:bundle];
	if (self) {
		NSLog(@"From ExpensesTableViewController init with nib");
	}
	return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Load the expenses
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" 
											  inManagedObjectContext:self.managedObjectContext]; 
	[request setEntity:entity];
	
	NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc]
									initWithKey:@"date" ascending:NO];
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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	NSArray *sections = [resultsController sections];
    NSUInteger count = 0;
    if ([sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    }
	return count;
}


// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//	NSLog(@"Asked for row number %i", indexPath.row);
//	
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//	// Configure the cell.
//	
//	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
//	
//	cell.textLabel.text = @"Some text"; //[[managedObject valueForKey:@"timeStamp"] description];
//	
//    return cell;
//}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"TransactionCell";
    
    TransactionTableCell *cell = (TransactionTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"TransactionCell" owner:self options:nil]; 
		cell = self.tableCell;
    }
    	
	Transaction *trs = (Transaction *)[resultsController objectAtIndexPath:indexPath];

	[cell setValuesWithTransaction:trs];
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[managedObjectContext release];
	[resultsController release];
	[tableCell release];
	[super dealloc];
}


@end

