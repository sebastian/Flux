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

@synthesize appDelegate;
@synthesize resultsController;

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
	
//	self.appDelegate = [[UIApplication sharedApplication] delegate];
//	
//	// Load the expenses
//	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
//	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" 
//											  inManagedObjectContext:self.appDelegate.managedObjectContext]; 
//	[request setEntity:entity];
//	
//	NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc]
//									initWithKey:@"date" ascending:NO];
//	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByDate, nil]; 
//	[request setSortDescriptors:sortDescriptors]; 
//	[sortDescriptors release]; 
//	[sortByDate release]; 
//	
//	NSError *error; 
//	NSFetchedResultsController * localRC = [[NSFetchedResultsController alloc] 
//											initWithFetchRequest:request 
//											managedObjectContext:self.appDelegate.managedObjectContext 
//											sectionNameKeyPath:nil cacheName:@"transactionCache"]; 
//	localRC.delegate=self;
//	
//	self.resultsController = localRC;
//	[localRC release];
//	
//	if ([self.resultsController performFetch:&error]) { 
//		NSLog(@"Error when performing fetch in messageTableViewController");
//		//NSLog([error localizedDescription]);
//	} 	
//	[request release]; 
	
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    //return [[resultsController sections] count];
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	id <NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:section];
//    return [sectionInfo numberOfObjects];
	NSLog(@"Asked for number of rows in section %i", section);
	return 4;
}


//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
////	NSUInteger count = [[resultsController sections] count];
////    if (count == 0) {
////        count = 1;
////    }
////    return count;
//	return 1;	
//}
//// Customize the number of rows in the table view.
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//
////	NSArray *sections = [resultsController sections];
////    NSUInteger count = 0;
////    if ([sections count]) {
////        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
////        count = [sectionInfo numberOfObjects];
////    }
////	return count;
//
//	return 5;
//}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSLog(@"Asked for row number %i", indexPath.row);
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	
//	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = @"Some text"; //[[managedObject valueForKey:@"timeStamp"] description];
	
    return cell;
}

// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    static NSString *CellIdentifier = @"TransactionCell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
////	Transaction *trs = (Transaction *)[resultsController objectAtIndexPath:indexPath];
//	
//	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//	cell.textLabel.text = @"Test"; //[trs toString];
//	//cell.detailTextLabel.text = @"An expense";
//	
//    return cell;
//}


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
	[resultsController release];
	[super dealloc];
}


@end

