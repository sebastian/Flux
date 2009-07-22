//
//  ExpensesTableViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverviewTableCell.h"
#import "DetailHeaderView.h"
#import "DetailContentTableCell.h"
#import "DetailFooterView.h"

@interface ExpensesTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController * resultsController;
	NSManagedObjectContext *managedObjectContext;
	
	OverviewTableCell * overviewTableCell;
	DetailHeaderView * detailHeaderView;
	DetailContentTableCell * detailContentTableCell;
	DetailFooterView * detailFooterView;
	
	UISegmentedControl * modeCtrl;
}

- (id)initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext*)context;
-(NSInteger) selectedSegment;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController * resultsController;

@property (nonatomic, retain) UISegmentedControl * modeCtrl;

//Different table cells
@property (nonatomic, retain) IBOutlet OverviewTableCell * overviewTableCell;
@property (nonatomic, retain) IBOutlet DetailHeaderView * detailHeaderView;
@property (nonatomic, retain) IBOutlet DetailContentTableCell * detailContentTableCell;
@property (nonatomic, retain) IBOutlet DetailFooterView * detailFooterView;

@end
