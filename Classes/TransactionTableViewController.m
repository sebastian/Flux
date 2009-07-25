//
//  TransactionTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 24.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionTableViewController.h"


@implementation TransactionTableViewController

@synthesize resultsController;
@synthesize managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext*)context {
	
	self = [super initWithStyle:style];
	if (self != nil) {
		self.managedObjectContext = context;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

// To be implemented by kids
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {return nil;}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
}



- (void)dealloc {
	[managedObjectContext release];
	[resultsController release];	
	
	[super dealloc];
	
}


#pragma mark
#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

///*
// Assume self has a property 'tableView', as is the case for an instance of a UITableViewController
// subclass, and a method configureCell:atIndexPath: which updates the contents of a given cell
// with information from a managed object at the given index path in the fetched results controller.
// */
//
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
//}
//
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//	
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//			 withRowAnimation:UITableViewRowAnimationFade];
//            break;
//			
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//			 withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//	  newIndexPath:(NSIndexPath *)newIndexPath {
//	
//    UITableView *tableView = self.tableView;
//	
//    switch(type) {
//			
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
//							 withRowAnimation:UITableViewRowAnimationFade];
//            break;
//			
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//							 withRowAnimation:UITableViewRowAnimationFade];
//            break;
//			
//			//        case NSFetchedResultsChangeUpdate:
//			//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
//			//					atIndexPath:indexPath];
//			//            break;
//			
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//							 withRowAnimation:UITableViewRowAnimationFade];
//            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section]
//					 withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView endUpdates];
//}

@end

