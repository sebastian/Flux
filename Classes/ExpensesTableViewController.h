//
//  ExpensesTableViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionTableCell.h"


@interface ExpensesTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController * resultsController;
	NSManagedObjectContext *managedObjectContext;
	
	TransactionTableCell * tableCell;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController * resultsController;
@property (nonatomic, retain) IBOutlet TransactionTableCell * tableCell;

@end
