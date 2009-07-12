//
//  ExpensesTableViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FinanceCoreDataDelegate.h"

@interface ExpensesTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NSFetchedResultsControllerDelegate> {
	id <FinanceCoreDataDelegate> delegate;
	NSFetchedResultsController * resultsController;
}

@property (nonatomic, retain) NSFetchedResultsController * resultsController;
@property (nonatomic, retain) IBOutlet id <FinanceCoreDataDelegate> delegate;

@end
