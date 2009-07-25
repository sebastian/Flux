//
//  TransactionTableViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 24.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface TransactionTableViewController : UITableViewController  <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController * resultsController;
	NSManagedObjectContext *managedObjectContext;
	UISegmentedControl * modeCtrl;
}

- (id)initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext*)context;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController * resultsController;
@property (nonatomic, retain) UISegmentedControl * modeCtrl;

@end
